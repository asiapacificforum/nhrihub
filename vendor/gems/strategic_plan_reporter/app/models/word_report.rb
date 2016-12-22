class WordReport
  attr_accessor :word_doc
  def initialize
    create_temp_dir
    copy_template
    generate_word_doc
    save_word_doc
    zip_it_up
  end

  def create_temp_dir
    `mkdir #{TMP_DIR}`
  end

  def copy_template
    FileUtils.cp_r(template_source,TMP_DIR)
  end

  def template_source
    Root.join(TEMPLATE_PATH,'docx/')
  end

  def save_word_doc
    file = File.open(TMP_DIR.join('docx','word','document.xml'),'w+')
    file.write(@word_doc)
    file.close
  end

  def zip_it_up
    FileUtils.cd(TMP_DIR.join('docx')) do
      system "zip -qr #{tmpfile} . -x \*.DS_Store \*.git/\* \*.gitignore \*.gitkeep"
    end
  end

  def docfile
    File.new(tmpfile)
  end

  def tmpfile
    Rails.root.join(TMP_DIR, docfile_name)
  end

  def docfile_name
    # overwrite this in the subclass if it's not appropriate
    self.class.name.underscore+'.docx'
  end

  def to_xml
    xml
  end

  def template(name)
    File.read(Root.join(TEMPLATE_PATH,name))
  end
end
