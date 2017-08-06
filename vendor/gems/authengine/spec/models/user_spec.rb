#require 'spec_helper'
require 'rails_helper'
require 'i18n'

describe "when a new user is added" do
  it "a registration email should be sent" do
    expect{FactoryGirl.create(:user)}.to change{ActionMailer::Base.deliveries.size}.by 1
  end

  it "email should have 'Please activate' etc in subject" do
    expect(ActionMailer::Base.deliveries.last.subject).to include I18n.t('authengine.user_mailer.signup_notification.subject', :org_name => ORGANIZATION_NAME, :app_name => APPLICATION_NAME)
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

describe "staff scope" do
  before do
    @staff_user = FactoryGirl.create(:user, :staff)
    @admin_user = FactoryGirl.create(:user, :admin)
  end

  it "should include users who have staff role assigned" do
    expect(User.staff).to include @staff_user
  end

  it "should not include users who do not have staff role assigned" do
    expect(User.staff).not_to include @admin_user
  end
end

describe "password confirmation" do
  before do
    @user = FactoryGirl.create(:user)
  end

  context "when account is activated" do
    it "should validate password when password confirmation matches" do
      @user.update_attributes(:password => "sekret", :password_confirmation => "sekret")
      @user.send(:activate!)
      expect(@user.errors).to be_empty
      expect(@user.activation_code).not_to be_blank
    end

    it "should not validate password when password confirmation does not match" do
      @user.update_attributes(:password => "sekret", :password_confirmation => "another_word")
      expect(@user.errors).not_to be_empty
      expect(@user.activation_code).not_to be_blank
    end
  end

  context "when a password reset has been initiated" do
    before do
      @user.update_attributes(:password => "sekret", :password_confirmation => "sekret", :password_reset_code => "abc23234fab")
    end

    it "should validate password when password confirmation matches" do
      @user.update_attributes(:password => "sekret", :password_confirmation => "sekret")
      @user.reset_password
      expect(@user.errors).to be_empty
      expect(@user.password_reset_code).to be_blank
    end

    it "should not validate password when password confirmation does not match" do
      @user.update_attributes(:password => "sekret", :password_confirmation => "another_word")
      expect(@user.errors).not_to be_empty
      expect(@user.password_reset_code).not_to be_nil
    end
  end
end
