require Rails.root.join('app','domain_models','report_utilities','report_template.rb')

namespace :complaints do
  desc "Creates template for complaint form from a raw MSWord document lib/source_docs/complaint_form.docx"
  task :generate_complaint_form_template => :environment do
    ReportTemplate.new(ComplaintReport, :list => false)
  end

  desc "Creates template for complaints list from a raw MSWord document lib/source_docs/complaints_list.docx"
  task :generate_complaints_list_template => :environment do
    ReportTemplate.new(ComplaintsReport, :list => true)
  end
end
