class ComplaintReport < WordReport
  attr_accessor :complaint,:witness_name
  def initialize(complaint,witness)
    @witness_name = witness.first_last_name
    @complaint = complaint
    super()
  end

  def generate_word_doc
    @word_doc = template.gsub(/\{\{\s*(\w*)\s*\}\}/) do |s|
      $1 == 'witness_name' ? witness_name : complaint.send($1).to_s
    end
  end

  def template
    @template ||= File.read(Root.join(TEMPLATE_PATH,'docx','word','document.xml'))
  end
end
