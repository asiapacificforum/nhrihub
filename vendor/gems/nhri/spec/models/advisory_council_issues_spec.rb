require 'rails_helper'

describe "article_link" do
  it "should convert 'null' string to nil value" do
    issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.create(:article_link => "null")
    expect(issue.reload.article_link).to be_nil
  end
end
