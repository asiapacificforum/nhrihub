module ListReport
  def generate_word_doc
    tail_template = File.read(self.class::Root.join(self.class::TEMPLATE_PATH, "_tail.xml"))
    item_template = File.read(self.class::Root.join(self.class::TEMPLATE_PATH, "_list_item_template.xml"))
    list = interpolate_list(items, item_template)
    @word_doc = head + list + tail_template
    generate_header
  end

  def generate_header
    header_template = self.class::Root.join(self.class::TEMPLATE_PATH, "docx", "word", "header1.xml")
    header_file = self.class::TMP_DIR.join('docx', 'word', "header1.xml")
    IO.write(header_file, File.open(header_template) do |f|
      interpolate(f.read, OpenStruct.new(:print_date => Date.today ))
    end)
  end

  def head
    head_template = File.read(self.class::Root.join(self.class::TEMPLATE_PATH, "_head.xml"))
    interpolate(head_template, OpenStruct.new(:query_string => "foo", :print_date => Date.today ))
  end

  def interpolate_list(list,template)
    list.map { |item| interpolate(template, item) }.join
  end

  def interpolate(template,object)
    template.gsub(/\{\{\s*(\w*)\s*\}\}/) { ERB::Util.html_escape(object.send($1).to_s) }
  end
end
