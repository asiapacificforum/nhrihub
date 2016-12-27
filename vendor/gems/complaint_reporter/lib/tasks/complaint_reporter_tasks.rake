require_relative '../../../../../app/domain_models/docx_cleaner.rb'
def cleanup
  file_name = ComplaintReporter::Engine.root.join('app','views','complaint_reporter','complaints','docx','word','document.xml')
  file = File.open(file_name,File::RDWR||File::TRUNC)
  xml = file.read
  file.truncate(0)
  file.close
  file = File.open(file_name,File::RDWR||File::TRUNC)
  # explanation:
  # MSWord can break up text elements into separate xml text nodes
  # DocxCleaner#consolidate brings these nodes back together again
  # so that substitutions can be made for the {{ value }} moustache pattern
  dc = DocxCleaner.new(xml)
  xml = dc.consolidate
  file.write(xml)
  file.close
end

namespace :complaints do
  desc "Creates template for complaint form from a raw MSWord document lib/source_docs/complaint_form.docx"
  task :generate_complaint_form_template do
    source_docs = ComplaintReporter::Engine.root.join('lib','source_docs')
    target = ComplaintReporter::Engine.root.join('app','views','complaint_reporter','complaints','docx')
    system "rm -rf #{target}"
    system "mkdir #{target}"
    FileUtils.cd(source_docs) do
      system "unzip -u complaint_form.docx -d #{target}"
    end
    cleanup
  end
end
