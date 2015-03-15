require 'spec_helper'

describe "when a new user is added" do
  before(:each) do
    user = FactoryGirl.create(:user)
  end

  it "a registration email should be sent" do
    ActionMailer::Base.deliveries.size.should == 1
  end

  it "email should have 'Please activate' etc in subject" do
    ActionMailer::Base.deliveries.last.subject.should == "Test database - Please activate your new account"
  end
end

describe "#initials method" do
  it "returns the user's capitalized initials" do
    user = FactoryGirl.create(:user, :firstName => 'frank', :lastName => 'Herbert')
    expect(user.initials).to eq 'FH'
  end
end

describe "email uniqueness validation" do
  it "should declare invalid if another active user has the email" do
    FactoryGirl.create(:user, :email => 'foo@bar.co', :status => 'active')
    user = FactoryGirl.build(:user, :email => 'foo@bar.co')
    expect(user.valid?).to be false
  end

  it "should declare invalid if another active user has the same email with alternative case" do
    FactoryGirl.create(:user, :email => 'Foo@bar.co', :status => 'active')
    user = FactoryGirl.build(:user, :email => 'foo@bar.co')
    expect(user.valid?).to be false
  end

  it "should declare valid if no other user has the email" do
    FactoryGirl.create(:user, :email => 'baz@bar.co', :status => 'active')
    user = FactoryGirl.build(:user, :email => 'foo@bar.co')
    expect(user.valid?).to be true
  end
end
