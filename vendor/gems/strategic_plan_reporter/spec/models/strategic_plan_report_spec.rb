require 'rails_helper'
$:.unshift File.expand_path '../../helpers', __FILE__

feature "strategic plan report" do
  scenario "it should produce valid xml with weird characters in fields" do
    strategic_plan = FactoryGirl.create(:strategic_plan, :title => "<</&&>>")
    sp = FactoryGirl.create(:strategic_priority, :strategic_plan_id => strategic_plan.id, :description => "<</&&>")
    pr = FactoryGirl.create(:planned_result, :strategic_priority => sp, :description => "words and things<</&&")
    o = FactoryGirl.create(:outcome, :planned_result => pr, :description => "<</&&>>")
    a = FactoryGirl.create(:activity, :outcome => o, :description => "<</&&>>", :progress => "<</&&>>")
    FactoryGirl.create(:performance_indicator, :well_populated, :activity => a, :description => "<</?&&>>", :target => "<<<?**??/")

    sp_report = StrategicPlanReport.new(strategic_plan)
    report = sp_report.generate_word_doc
    docx = File.read(StrategicPlanReport::TMP_DIR.join('docx', 'word', 'document.xml').to_s)
    xml_doc = Nokogiri::XML(docx)
    expect(xml_doc.errors).to be_empty
  end
end


