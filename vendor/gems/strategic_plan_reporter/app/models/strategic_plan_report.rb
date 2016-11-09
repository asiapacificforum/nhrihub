class StrategicPlanReport
  include ViewPath
  attr_accessor :tmpdir, :strategic_plan, :word_doc
  def initialize(strategic_plan)
    @strategic_plan = strategic_plan
    create_temp_dir
    copy_template
    generate_word_doc
  end

  def docfile
    File.new(Rails.root.join(TMP_DIR, 'strategic_plan_report.docx'))
  end

  def generate_word_doc
    @word_doc = head
    strategic_plan.strategic_priorities.each do |strategic_priority|
      @word_doc += StrategicPriorityReport.new(strategic_priority).to_xml
    end
    @word_doc += tail
    save_word_doc
    zip_it_up
  end

  def zip_it_up
    FileUtils.cd(Rails.root.join(TMP_DIR,'strategic_priority')) do
      system "zip -qr #{Rails.root.join(TMP_DIR,'strategic_plan_report.docx')} . -x \*.DS_Store \*.git/\* \*.gitignore \*.gitkeep"
    end
  end

  def head
    template('_head.xml')
  end

  def tail
    template('_tail.xml')
  end

  def save_word_doc
    file = File.open(Rails.root.join(TMP_DIR,'strategic_priority','word','document.xml'),'w+')
    file.write(@word_doc)
    file.close
  end

  def copy_template
    FileUtils.cp_r(template_source,Rails.root.join(TMP_DIR))
  end

  def template_source
    Root.join(TEMPLATE_PATH,'strategic_priority/')
  end

  def create_temp_dir
    unless Dir.exists? Rails.root.join(TMP_DIR)
      `mkdir #{Rails.root.join(TMP_DIR)}`
    end
    @tmpdir = Dir.new Rails.root.join(TMP_DIR)
  end
end
