class LoremIpsumDocument < WordReport
  Root = Rails.root
  TMP_DIR = Root.join('tmp','tmp_doc')
  TEMPLATE_PATH = Root.join('app', 'templates', 'msword_template')

  def generate_word_doc
    @word_doc = template.gsub(/\{\{\s*(\w*)\s*\}\}/) do |s|
      ERB::Util.html_escape(send($1))
    end
  end

  def template
    @template ||= File.read(Root.join(TEMPLATE_PATH,'docx','word','document.xml'))
  end

  def title
    Faker::Lorem.words(5).join(' ').titleize
  end

  def heading
    Faker::Lorem.words(3).join(' ').titleize
  end

  def text
    Faker::Lorem.paragraph
  end

end
