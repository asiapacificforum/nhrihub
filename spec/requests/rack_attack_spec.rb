require 'rails_helper'

describe "root path only accepts get requests" do
  before do
    allow(ENV).to receive(:fetch)
    allow(ENV).to receive(:fetch).with("two_factor_authentication").and_return("disabled") #so we don't trigger browser check responses
  end

  it "returns 'forbidden' for put request"  do
    put "/"
    expect(response.status).to eq 403
  end

  it "returns 'forbidden' for put request, with locale"  do
    put "/en/"
    expect(response.status).to eq 403
  end

  it "returns 'forbidden' for post request" do
    post "/"
    expect(response.status).to eq 403
  end

  it "returns 'forbidden' for post request with locale" do
    post "/en/"
    expect(response.status).to eq 403
  end

  it "returns 'forbidden' for delete request" do
    delete "/"
    expect(response.status).to eq 403
  end

  it "returns 'forbidden' for delete request with locale" do
    delete "/en/"
    expect(response.status).to eq 403
  end

  it "returns 'ok' for get request" do
    get "/"
    follow_redirect!
    expect(response.status).to eq 200
  end

  it "returns 'ok' for get request, with locale" do
    get "/en/"
    expect(response.status).to eq 200
  end
end

describe "forbidden url patterns" do
  before do
    allow(ENV).to receive(:fetch)
    allow(ENV).to receive(:fetch).with("two_factor_authentication").and_return("disabled") #so we don't trigger browser check responses
  end

  ["wp-admin", "wp-login", "wp-content", "/etc/passwd"].each do |pattern|
    it "should return 403 when reqest url matches #{pattern}" do
      get "/en/#{pattern}/other/path/components"
      expect(response.status).to eq 403
    end
  end
end

describe "php pattern" do
  before do
    allow(ENV).to receive(:fetch)
    allow(ENV).to receive(:fetch).with("two_factor_authentication").and_return("disabled") #so we don't trigger browser check responses
  end

  it "when script is requested should return 403" do
    get "/en/some/path/to/endpoint.php"
    expect(response.status).to eq 403
  end

  it "when phpmyadmin is requested should return 403" do
    get "/en/some/path/to/phpmyadmin"
    expect(response.status).to eq 403
  end
end

describe "legitimate urls" do
  before do
    allow(ENV).to receive(:fetch)
    allow(ENV).to receive(:fetch).with("two_factor_authentication").and_return("disabled") #so we don't trigger browser check responses
  end

  it "should return ok" do
    post "/en/authengine/sessions"
    expect(response.status).to eq 200
  end
end
