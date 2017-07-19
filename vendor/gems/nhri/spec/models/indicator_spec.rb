require 'rails_helper'

describe "#index_url" do
  before do
    heading = Nhri::Heading.create
    @indicator = Nhri::Indicator.create(:heading => heading)
  end

  it "should contain protocol, host, locale, indicators path, and id query string" do
    route = Rails.application.routes.recognize_path(@indicator.index_url)
    expect(route[:locale]).to eq I18n.locale.to_s
    url = URI.parse(@indicator.index_url)
    expect(url.host).to eq SITE_URL
    expect(url.path).to eq "/en/nhri/headings/1"
    params = CGI.parse(url.query)
    expect(params.keys.first).to eq "selected_indicator_id"
    expect(params.values.first).to eq [@indicator.id.to_s]
  end
end
