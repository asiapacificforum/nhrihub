require 'rails_helper'

describe "Sessions" do
  describe "GET /" do
    it "should show the login page" do
      get root_path(:en)
      expect(response.status).to eq 200
      expect(response.body).to include "Please log in"
    end
  end
end
