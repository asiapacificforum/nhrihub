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

  ATTRIBUTES = "(?:(?:\s[^>]*?)*?)"
  OPENTAG =    "<w:t#{ATTRIBUTES}>"
  CLOSETAG = "<\/w:t>"

  def consolidate_double_open_braces
    self.xml = xml.gsub(/#{OPENTAG}\s*?{\s*?#{CLOSETAG}.*?#{OPENTAG}\s*?{\s*?<\/w:t>/,'<w:t>{{</w:t>')
  end

  def consolidate_double_close_braces
    self.xml = xml.gsub(/#{OPENTAG}\s*?}\s*?#{CLOSETAG}.*?#{OPENTAG}\s*?}\s*?<\/w:t>/,'<w:t>}}</w:t>')
  end

  def consolidate_text_nodes
    @moustache = false
    #                    $1 $2             $3
    self.xml = xml.gsub(/((.*?)#{OPENTAG}(.*?)#{CLOSETAG})/) do |s|
      r1, r2, r3 = $1, $2, $3
      if r3 =~ /{{.*?}}/
        r1
      elsif r3 =~ /{{/
        @moustache = true
        "#{r2}<w:t>{{"
      elsif r3 =~ /}}/
        @moustache = false
        "}}</w:t>"
      elsif @moustache
        r3
      else
        r1
      end
    end
    xml
  end
end
