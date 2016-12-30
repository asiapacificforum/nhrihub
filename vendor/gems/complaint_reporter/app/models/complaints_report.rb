class ComplaintsReport < WordReport
  Root = ComplaintReport::Root
  TMP_DIR = ComplaintReport::TMP_DIR
  TEMPLATE_PATH = 'app/views/complaint_reporter/complaints'
  SourceDoc = 'complaints_list.docx'
  attr_accessor :complaints
  def initialize(complaints)
    @complaints = complaints
    super()
  end

  def generate_word_doc
    tail_template = File.read(Root.join(TEMPLATE_PATH, "_tail.xml"))
    complaint_template = File.read(Root.join(TEMPLATE_PATH, "_complaint_template.xml"))
    complaint_items = interpolate_list(complaints, complaint_template)
    @word_doc = head + complaint_items + tail_template
    generate_header
  end

  def generate_header
    header_template = Root.join(TEMPLATE_PATH, "docx", "word", "header1.xml")
    header_file = TMP_DIR.join('docx', 'word', "header1.xml")
    IO.write(header_file, File.open(header_template) do |f|
      interpolate(f.read, OpenStruct.new(:print_date => Date.today ))
    end)
  end

  def head
    head_template = File.read(Root.join(TEMPLATE_PATH, "_head.xml"))
    interpolate(head_template, OpenStruct.new(:query_string => "foo", :print_date => Date.today ))
  end

  def interpolate_list(list,template)
    list.map { |item| interpolate(template, item) }.join
  end

  def interpolate(template,object)
    template.gsub(/\{\{\s*(\w*)\s*\}\}/) { object.send($1).to_s }
  end
end
