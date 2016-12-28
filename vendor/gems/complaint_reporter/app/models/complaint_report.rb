class ComplaintReport < WordReport
  attr_accessor :complaint,:witness_name
  def initialize(complaint,witness)
    @witness_name = witness.first_last_name
    @complaint = complaint
    super()
  end

  def generate_word_doc
    fields = Complaint.new.attributes.keys + ['report_date', 'complainant_full_name', 'witness_name']
    fields.each do |attribute|
      value = (attribute == 'witness_name') ? witness_name : complaint.send(attribute).to_s
      @template = template.gsub(/\{\{\s*#{attribute}\s*\}\}/,value)
    end
    @word_doc = @template
  end

  def template
    @template ||= File.read(Root.join(TEMPLATE_PATH,'docx','word','document.xml'))
  end
end
