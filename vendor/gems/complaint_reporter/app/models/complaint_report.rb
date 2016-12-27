class ComplaintReport < WordReport
  attr_accessor :complaint
  def initialize(complaint)
    @complaint = complaint
    super()
  end

  def generate_word_doc
    Complaint.new.attributes.keys.each do |attribute|
      @template = template.gsub(/\{\{\s*#{attribute}\s*\}\}/,complaint.send(attribute).to_s)
    end
    @word_doc = @template
  end

  def template
    @template ||= File.read(Root.join(TEMPLATE_PATH,'docx','word','document.xml'))
  end
end
