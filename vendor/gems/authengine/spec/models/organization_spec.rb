require 'spec_helper'

describe "active scope" do
  before do
    @active_organization = FactoryGirl.create(:organization, :active, :pantry)
    @inactive_organization = FactoryGirl.create(:organization, :inactive, :pantry)
  end
  let(:active_organizations){ Organization.active }
  let(:inactive_organizations){ Organization.inactive }

  it "should retrieve a single active organization" do
    expect(active_organizations.size).to eq 1
    expect(active_organizations.first).to eq @active_organization
  end

  it "should retrieve a single inactive organization" do
    expect(inactive_organizations.size).to eq 1
    expect(inactive_organizations.first).to eq @inactive_organization
  end
end

describe "model validation" do
  it "should raise an error if neither the pantry nor the referrer attributes are true" do
    expect{ FactoryGirl.create(:organization, :active) }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "should not raise an error if the pantry attribute is true" do
    expect{ FactoryGirl.create(:organization, :active, :pantry) }.not_to raise_error
  end

  it "should not raise an error if the referrer attribute is true" do
    expect{ FactoryGirl.create(:organization, :active, :referrer) }.not_to raise_error
  end
end

describe "model uniqueness validation" do
  before do
    FactoryGirl.create(:organization, :referrer, :name => "Food for you")
    @org = FactoryGirl.build(:organization, :referrer, :name => "Food for you")
    @org.valid?
  end

  it "should populate the error message" do
    expect( @org.errors.full_messages.join(" ")).to include("Referrer already exists, referrer name must be unique.")
  end
end

