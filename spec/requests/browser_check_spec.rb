require 'rails_helper'

describe "user logs in from non-chrome browser when two-factor authentication is enabled" do
  before do
    allow(ENV).to receive(:fetch)
    allow(ENV).to receive(:fetch).with("two_factor_authentication").and_return("enabled")
    allow(Apf::Application.config).to receive(:consider_all_requests_local).and_return(false)
  end

  it "When browser is chrome, it should show the login page" do
    headers = { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36'}
    get root_path(:en), :headers => headers
    expect(response.status).to eq 200
    expect(response.body).to include "Please log in"
  end

  it "When browser is firefox, it should redirect to error page" do
    headers = { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:40.0) Gecko/20100101 Firefox/40.0'}
    get home_path(:en), :headers => headers
    expect(response.status).to eq 422
    expect(response.body).to match /<h2>You must use the Chrome browser/
  end

  it "When an invalid route is requested" do
    get "/en/bad_path"
    expect(response.status).to eq 404
    expect(response.body).to match /<h1>The page you were looking for doesn't exist/
  end
end
