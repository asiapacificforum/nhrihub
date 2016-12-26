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
    @moustache = false
    open_tag = "<w:t(?:(?:\s.*?)*?)>"
    close_tag = "<\/w:t(?:(?:\s.*?)*?)>"
    self.xml = xml.gsub(/((.*?)#{open_tag}(.*?)#{close_tag})/) do |s|
      if $3 == "{{"
        @moustache = true
        "#{$2}<w:t>{{"
      elsif $3 == "}}"
        @moustache = false
        "}}</w:t>"
      elsif @moustache
        $3
      else
        $1
      end
    end
    xml
  end
end
