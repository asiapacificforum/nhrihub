require 'rails_helper'

describe "exception pages" do
  before do
    allow(Apf::Application.config).to receive(:consider_all_requests_local).and_return(false)
  end

  it "not found" do
    get "/not_found"
    follow_redirect!
    expect(response.status).to eq 404
    expect(response.body).to match /<h1>The page you were looking for doesn't exist/
  end

  it "method_not_allowed" do
    get"/method_not_allowed"
    follow_redirect!
    expect(response.status).to eq 405
    expect(response.body).to match /Oops/
  end

  it "not_implemented" do
    get"/not_implemented"
    follow_redirect!
    expect(response.status).to eq 501
    expect(response.body).to match /Oops/
  end

  it "not_acceptable" do
    get"/not_acceptable"
    follow_redirect!
    expect(response.status).to eq 406
    expect(response.body).to match /Oops/
  end

  it "unprocessable_entity" do
    get"/unprocessable_entity"
    follow_redirect!
    expect(response.status).to eq 422
    expect(response.body).to match /Oops/
  end

  it "bad_request" do
    get"/bad_request"
    follow_redirect!
    expect(response.status).to eq 400
    expect(response.body).to match /Oops/
  end

  it "conflict" do
    get"/conflict"
    follow_redirect!
    expect(response.status).to eq 409
    expect(response.body).to match /Oops/
  end

  it "When an invalid route is requested" do
    get "/bad_path"
    follow_redirect!
    expect(response.status).to eq 404
    expect(response.body).to match /<h1>The page you were looking for doesn't exist/
  end
end
