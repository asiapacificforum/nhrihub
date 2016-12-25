require 'byebug'
class DocxCleaner
  attr_accessor :xml

  def initialize(x)
    @xml = x
  end

  def consolidate
    consolidate_double_close_braces
    consolidate_double_open_braces
    consolidate_text_nodes
    xml
  end

  def consolidate_double_open_braces
    self.xml = xml.gsub(/<w:t>{<\/w:t>.*?<w:t>{<\/w:t>/,'<w:t>{{</w:t>')
  end

  def consolidate_double_close_braces
    self.xml = xml.gsub(/<w:t>}<\/w:t>.*?<w:t>}<\/w:t>/,'<w:t>}}</w:t>')
  end

  def consolidate_text_nodes
    self.xml = xml.gsub(/(?:.*?<w:t.*?>(.*?)<\/w:t>.*?)/) do |s|
      if $1 == "{{"
        "<w:t>{{"
      elsif $1 == "}}"
        "}}</w:t>"
      else
        $1
      end
    end
    #sub = xml.gsub(/<w:t>(\w*)<\/w:t>.*?<w:t>(\w*)<\/w:t>/,'<w:t>\1\2</w:t>')
    #unless sub == xml
      #self.xml = sub
      #consolidate_text_nodes
    #end
    xml
  end
end
