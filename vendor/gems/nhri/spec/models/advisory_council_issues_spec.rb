require 'rails_helper'

describe "article_link" do
  it "should convert 'null' string to nil value" do
    issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.create(:article_link => "null")
    expect(issue.reload.article_link).to be_nil
  end
end

describe "index_url" do
  context "when query string is appended" do
    it "should append query string with supplied query parameter" do
      issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.new(:title => "the big issue")
      expect(issue.index_url).to eq "/en/nhri/advisory_council/issues?selection=the+big+issue"
    end
  end
end
