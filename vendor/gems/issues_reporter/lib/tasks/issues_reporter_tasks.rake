require Rails.root.join('app','domain_models','docx_cleaner.rb')

def generate_issue_template(context)
  source_docs = context::Root.join('lib','source_docs')
  target = context::Root.join(context::TEMPLATE_PATH,'docx')
  file_name = target.join('word','document.xml')
  system "rm -rf #{target.join('*')}"
  FileUtils.cd(source_docs) { system "unzip -u #{context::SourceDoc} -d #{target}" }
  IO.write(file_name, File.open(file_name) { |f| DocxCleaner.new(f.read).consolidate })
end

def split_template
  view_path = IssuesReport::Root.join(IssuesReport::TEMPLATE_PATH)
  file_name = view_path.join('docx', 'word','document.xml')
  template = File.open(file_name){ |f| f.read }
  end_of_row_tag = "</w:tr>"
  head, issue_template, tail = template.split(end_of_row_tag)
  IO.write(view_path.join("_head.xml"),head+end_of_row_tag)
  IO.write(view_path.join("_issue_template.xml"),issue_template+end_of_row_tag)
  IO.write(view_path.join("_tail.xml"),tail)
end

def cleanup_header
  header_template = IssuesReport::Root.join(IssuesReport::TEMPLATE_PATH, "docx", "word", "header1.xml")
  IO.write(header_template, File.open(header_template) { |f| DocxCleaner.new(f.read).consolidate })
end

namespace :advisory_council_issues do
  desc "Creates template for issues list from a raw MSWord document lib/source_docs/issues_list.docx"
  task :generate_issues_list_template => :environment do
    generate_issue_template(IssuesReport)
    split_template
    cleanup_header
  end
end
