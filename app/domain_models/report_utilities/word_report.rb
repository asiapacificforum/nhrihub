class WordReport
  attr_accessor :word_doc
  def initialize
    create_temp_dir
    copy_template
    generate_word_doc
    save_word_doc
    zip_it_up
  end

  def tmp_dir
    self.class.name.constantize::TMP_DIR
  end

  def template_path
    self.class.name.constantize::TEMPLATE_PATH
  end

  def create_temp_dir
    `mkdir #{tmp_dir}`
  end

  def copy_template
    FileUtils.cp_r(template_source,tmp_dir)
  end

  def template_source
    self.class.name.constantize::Root.join(template_path,'docx/')
  end

  def save_word_doc
    file = File.open(tmp_dir.join('docx','word','document.xml'),'w+')
    file.write(@word_doc)
    file.close
  end

  def zip_it_up
    FileUtils.cd(tmp_dir.join('docx')) do
      system "zip -qr #{tmpfile} . -x \*.DS_Store \*.git/\* \*.gitignore \*.gitkeep"
    end
  end

  def docfile
    File.new(tmpfile)
  end

  def tmpfile
    Rails.root.join(tmp_dir, docfile_name)
  end

  def docfile_name
    # overwrite this in the subclass if it's not appropriate
    self.class.name.underscore+'.docx'
  end

end
