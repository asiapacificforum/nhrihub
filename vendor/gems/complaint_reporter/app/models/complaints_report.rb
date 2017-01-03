require Rails.root.join('app', 'domain_models', 'report_utilities', 'list_report')

class ComplaintsReport < WordReport
  include ListReport
  Root = ComplaintReport::Root
  TMP_DIR = ComplaintReport::TMP_DIR
  TEMPLATE_PATH = 'app/views/complaint_reporter/complaints'
  SourceDoc = 'complaints_list.docx'
  attr_accessor :items
  def initialize(items)
    @items = items
    super()
  end

end
