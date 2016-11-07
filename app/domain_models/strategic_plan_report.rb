class StrategicPlanReport
  GEM_PATH = 'vendor/gems/corporate_services'
  STRATEGIC_PLAN_VIEW_PATH = 'app/views/corporate_services/strategic_plans'
  TMP_DIR = 'tmp/strategic_plan_report'
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
      @word_doc += strategic_priority_snippet(strategic_priority)
    end
    @word_doc += tail
    save_word_doc
    zip_it_up
  end

  def zip_it_up
    FileUtils.cd(Rails.root.join(TMP_DIR,'strategic_priority')) do
      system "zip -qr #{Rails.root.join(TMP_DIR,'strategic_plan_report.docx')} . -x \*.DS_Store \*.git/\* \*.gitignore \*.gitkeep"
    end
    #cleanup(dir)
  end

  def head
    File.read(Rails.root.join(GEM_PATH,STRATEGIC_PLAN_VIEW_PATH,'reports','strategic_plan','_head.xml'))
  end

  def tail
    File.read(Rails.root.join(GEM_PATH,STRATEGIC_PLAN_VIEW_PATH,'reports','strategic_plan','_tail.xml'))
  end

  def strategic_priority_template
    File.read(Rails.root.join(GEM_PATH,STRATEGIC_PLAN_VIEW_PATH,'reports','strategic_plan','_strategic_priority.xml'))
  end

  def outcome_template
    File.read(Rails.root.join(GEM_PATH,STRATEGIC_PLAN_VIEW_PATH,'reports','strategic_plan','_outcome.xml'))
  end

  def save_word_doc
    file = File.open(Rails.root.join(TMP_DIR,'strategic_priority','word','document.xml'),'w+')
    file.write(@word_doc)
    file.close
  end

  def strategic_priority_snippet(strategic_priority)
    @strategic_priority_template ||= strategic_priority_template
    @strategic_priority_template.gsub(/strategic_priority/, "Strategic Priority #{strategic_priority.index}: #{strategic_priority.description}")
    @strategic_priority_template +
    strategic_priority.outcomes.each do |outcome|
      @strategic_priority_template += outcome_snippet(outcome)
    end
  end

  def outcome_snippet(outcome)
    @outcome_template ||= outcome_template
    @outcome_template.gsub()
  end

  def copy_template
    FileUtils.cp_r(template_source,Rails.root.join(TMP_DIR))
  end

  def template_source
    Rails.root.join(GEM_PATH,STRATEGIC_PLAN_VIEW_PATH,'reports','strategic_plan','strategic_priority')
  end

  def create_temp_dir
    unless Dir.exists? Rails.root.join(TMP_DIR)
      `mkdir #{Rails.root.join(TMP_DIR)}`
    end
    @tmpdir = Dir.new Rails.root.join(TMP_DIR)
  end
end
