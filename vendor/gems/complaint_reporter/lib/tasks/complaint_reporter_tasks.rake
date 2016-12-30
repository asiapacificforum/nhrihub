require_relative '../../../../../app/domain_models/docx_cleaner.rb'

def generate_complaint_template(context)
  source_docs = context::Root.join('lib','source_docs')
  target = context::Root.join(context::TEMPLATE_PATH,'docx')
  file_name = target.join('word','document.xml')
  system "rm -rf #{target.join('*')}"
  FileUtils.cd(source_docs) { system "unzip -u #{context::SourceDoc} -d #{target}" }
  IO.write(file_name, File.open(file_name) { |f| DocxCleaner.new(f.read).consolidate })
end

def split_template
  view_path = ComplaintsReport::Root.join(ComplaintsReport::TEMPLATE_PATH)
  file_name = view_path.join('docx', 'word','document.xml')
  template = File.open(file_name){ |f| f.read }
  end_of_row_tag = "</w:tr>"
  head, complaint_template, tail = template.split(end_of_row_tag)
  IO.write(view_path.join("_head.xml"),head+end_of_row_tag)
  IO.write(view_path.join("_complaint_template.xml"),complaint_template+end_of_row_tag)
  IO.write(view_path.join("_tail.xml"),tail)
end

def cleanup_header
  header_template = ComplaintsReport::Root.join(ComplaintsReport::TEMPLATE_PATH, "docx", "word", "header1.xml")
  IO.write(header_template, File.open(header_template) { |f| DocxCleaner.new(f.read).consolidate })
end

namespace :complaints do
  desc "Creates template for complaint form from a raw MSWord document lib/source_docs/complaint_form.docx"
  task :generate_complaint_form_template => :environment do
    generate_complaint_template(ComplaintReport)
  end

  desc "Creates template for complaints list from a raw MSWord document lib/source_docs/complaints_list.docx"
  task :generate_complaints_list_template => :environment do
    generate_complaint_template(ComplaintsReport)
    split_template
    cleanup_header
  end
end
