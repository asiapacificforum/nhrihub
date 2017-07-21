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
      expect(issue.index_url).to match Regexp.escape "/en/nhri/advisory_council/issues?selection=the+big+issue"
    end
  end
end

describe "#index_url" do
  before do
    @issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.new(:title => "the big issue")
  end

  it "should contain protocol, host, locale, issues path, and case_reference query string" do
    route = Rails.application.routes.recognize_path(@issue.index_url)
    expect(route[:locale]).to eq I18n.locale.to_s
    url = URI.parse(@issue.index_url)
    expect(url.host).to eq SITE_URL
    expect(url.path).to eq "/en/nhri/advisory_council/issues"
    params = CGI.parse(url.query)
    expect(params.keys.first).to eq "selection"
    expect(params.values.first).to eq [@issue.title]
  end
end
