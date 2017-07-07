require 'rails_production_env_helper'

describe "user logs in from non-chrome browser when two-factor authentication is enabled" do
  before do
    allow(ENV).to receive(:fetch)
    allow(ENV).to receive(:fetch).with("two_factor_authentication").and_return("enabled")
  end

  it "When browser is chrome, it should show the login page" do
    headers = {'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36'}
    get root_path(:en), :headers => headers
    expect(response.status).to eq 200
    expect(response.body).to include "Please log in"
  end

  it "redirects not found to 404 page" do
    get "/bad_route"
    follow_redirect!
    expect(response.body).to include "too bad so sad"
  end

  it "When browser is internet explorer, it should redirect to error page" do
    headers = {'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:40.0) Gecko/20100101 Firefox/40.0'}
    get root_path(:en), :headers => headers
    expect(response).to redirect_to(where?)
    follow_redirect!
    expect(response.body).to include "You must use Chrome"
  end
end
