require 'rails_helper'
$:.unshift File.expand_path '../../helpers', __FILE__

feature "issues report" do
  scenario "it should produce valid xml with weird characters in fields" do
    issue = FactoryGirl.create(:advisory_council_issue, :title => "&&<<?//<<??>>")

    issues_report = IssuesReport.new([issue])
    report = issues_report.generate_word_doc
    docx = File.read(IssuesReport::TMP_DIR.join('docx', 'word', 'document.xml').to_s)
    xml_doc = Nokogiri::XML(docx)
    expect(xml_doc.errors).to be_empty
  end
end


