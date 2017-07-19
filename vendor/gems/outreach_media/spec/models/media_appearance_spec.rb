require 'rails_helper'

describe "#index_url" do
  before do
    @media_appearance = MediaAppearance.create(:title => 'the boy stood on the burning deck')
  end

  it "should contain protocol, host, locale, media_appearances path, and case_reference query string" do
    route = Rails.application.routes.recognize_path(@media_appearance.index_url)
    expect(route[:locale]).to eq I18n.locale.to_s
    url = URI.parse(@media_appearance.index_url)
    expect(url.host).to eq SITE_URL
    expect(url.path).to eq "/en/media_appearances"
    params = CGI.parse(url.query)
    expect(params.keys.first).to eq "title"
    expect(params.values.first).to eq [@media_appearance.title]
  end
end
