class ProgressReport
  include ViewPath

  attr_accessor :media_appearances, :projects, :progress_items, :xml

  def initialize(media_appearances, projects)
    @media_appearances, @projects = [media_appearances, projects]
    @progress_items = [media_appearances, projects].flatten
    generate_xml
  end

  def generate_xml
    @xml = ""
    i = 0
    @xml += blank_progress_report if @progress_items.length.zero?
    progress_items.each do |progress_item|
      @xml += progress_report(i==0,progress_item)
      i += 1
    end
  end

  def blank_progress_report
    progress_template(true).gsub(/progress/,'')
  end

  def progress_template(first)
    first ? template('_inline_progress.xml') : template('_progress.xml')
  end

  def progress_report(first, progress_item)
    progress_template(first).gsub(/progress/,progress_item.title)
  end

end
