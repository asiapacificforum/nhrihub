require Rails.root.join('app','domain_models','report_utilities','docx_cleaner.rb')

class ReportTemplate
  attr_accessor :context
  def initialize(context,options)
    @context = context
    generate_template(context)
    if options[:list]
      split_template
      cleanup_header
    end
  end

  def generate_template(context)
    source_docs = context::Root.join('lib','source_docs')
    target = context::Root.join(context::TEMPLATE_PATH,'docx')
    file_name = target.join('word','document.xml')
    system "rm -rf #{target.join('*')}"
    FileUtils.cd(source_docs) { system "unzip -u #{context::SourceDoc} -d #{target}" }
    IO.write(file_name, File.open(file_name) { |f| DocxCleaner.new(f.read).consolidate })
  end

  def split_template
    view_path = context::Root.join(context::TEMPLATE_PATH)
    file_name = view_path.join('docx', 'word','document.xml')
    template = File.open(file_name){ |f| f.read }
    end_of_row_tag = "</w:tr>"
    head, body, tail = template.split(end_of_row_tag)
    IO.write(view_path.join("_head.xml"),head+end_of_row_tag)
    IO.write(view_path.join("_list_item_template.xml"),body+end_of_row_tag)
    IO.write(view_path.join("_tail.xml"),tail)
  end

  def cleanup_header
    header_template = context::Root.join(context::TEMPLATE_PATH, "docx", "word", "header1.xml")
    IO.write(header_template, File.open(header_template) { |f| DocxCleaner.new(f.read).consolidate })
  end
end
