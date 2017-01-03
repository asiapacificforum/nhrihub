require Rails.root.join('app','domain_models','report_utilities','report_template.rb')

namespace :advisory_council_issues do
  desc "Creates template for issues list from a raw MSWord document lib/source_docs/issues_list.docx"
  task :generate_issues_list_template => :environment do
    ReportTemplate.new(IssuesReport, :list => true)
  end
end
