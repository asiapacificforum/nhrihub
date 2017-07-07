ENV['RAILS_I18N_LOCALE'] = 'fr'
require 'rails_helper'

describe "exceptions with alternative default locale" do
  before do
    allow(ENV).to receive(:fetch)
    allow(ENV).to receive(:fetch).with("two_factor_authentication").and_return("enabled")
    allow(Apf::Application.config).to receive(:consider_all_requests_local).and_return(false)
  end

  it "When an invalid route is requested with alternative locale" do
    get "/bad_path"
    follow_redirect!
    expect(response.status).to eq 404
    expect(response.body).to match /<h1>La page que vous recherchiez n'existe pas/
  end

  it "When an invalid route is requested with the default locale" do
    get "/en/bad_path"
    expect(response.status).to eq 404
    expect(response.body).to match /<h1>La page que vous recherchiez n'existe pas/
  end
end
