require 'rails_helper'

describe "#index_url" do
  before do
    @doc = IccReferenceDocument.create(:title => 'have a nice day')
  end

  it "should contain protocol, host, locale, docs path, and case_reference query string" do
    route = Rails.application.routes.recognize_path(@doc.index_url)
    expect(route[:locale]).to eq I18n.locale.to_s
    url = URI.parse(@doc.index_url)
    expect(url.host).to eq SITE_URL
    expect(url.path).to eq "/en/nhri/icc_reference_documents"
    params = CGI.parse(url.query)
    expect(params.keys.first).to eq "selected_document_id"
    expect(params.values.first).to eq [@doc.id.to_s]
  end
end
