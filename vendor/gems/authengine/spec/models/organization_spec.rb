#require 'spec_helper'
require 'rails_helper'

describe "model uniqueness validation" do
  before do
    FactoryGirl.create(:organization, :name => "Food for you")
    @org = FactoryGirl.build(:organization, :name => "Food for you")
    @org.valid?
  end

  it "should populate the error message" do
    expect( @org.errors.full_messages.join(" ")).to include("Organization name already exists, organization name must be unique.")
  end
end

