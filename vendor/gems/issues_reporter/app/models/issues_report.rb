require Rails.root.join('app', 'domain_models', 'report_utilities', 'list_report')

class IssuesReport < WordReport
  include ListReport
  Root = IssuesReporter::Engine.root
  TMP_DIR = Rails.root.join('tmp','issues')
  TEMPLATE_PATH = 'app/views/issues_reporter'
  SourceDoc = 'advisory_council_issues_list.docx'

  attr_accessor :items
  def initialize(items)
    @items = items
    super()
  end

end
