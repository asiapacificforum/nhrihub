require 'rails_helper'
#require 'spec_helper'
describe ".create_or_update class method" do
  context "when a user has no prior sessions" do
    before do
      user = FactoryGirl.create(:user)
      login = Session.create_or_update(:user_id => user.id, :session_id => rand(10**12).to_s, :login_date => Time.new(2014,5,15,10,10,00,"+00:00"))
    end

    it "should save the session" do
      expect(Session.count).to eq(1)
    end
  end

  context "when the user's previous session has no logout date" do
    before do
      user = FactoryGirl.create(:user)
      @login1 = Session.create_or_update(:user_id => user.id, :session_id => rand(10**12).to_s, :login_date => Time.new(2014,5,15,10,10,00,"+00:00"))
      @login2 = Session.create_or_update(:user_id => user.id, :session_id => rand(10**12).to_s, :login_date => Time.new(2014,5,16,10,10,00,"+00:00"))
    end

    it "should update the session_id and time of the previous session" do
      expect(Session.count).to eq(1)
      expect(Session.first.session_id).to eq(@login2.session_id)
      expect(Session.first.login_date).to eq(@login1.login_date)
    end
  end

  context "when the user has prior sessions with no logout, but the previous session has a logout date" do
    before do
      user = FactoryGirl.create(:user)
      login1 = Session.create_or_update(:user_id => user.id, :session_id => rand(10**12).to_s, :login_date => Time.new(2014,5,15,10,10,00,"+00:00"))
      login2 = Session.create_or_update(:user_id => user.id, :session_id => rand(10**12).to_s, :login_date => Time.new(2014,5,16,10,10,00,"+00:00"))
      login2.update_attributes(:logout_date => Time.new(2014,5,16,10,10,05,"+00:00"))
      @login3 = Session.create_or_update(:user_id => user.id, :session_id => rand(10**12).to_s, :login_date => Time.new(2014,5,17,10,10,00,"+00:00"))
    end

    it "should update the session_id and time of the previous session" do
      expect(Session.count).to eq(2)
      expect(Session.last.session_id).to eq(@login3.session_id)
      expect(Session.last.login_date).to eq(@login3.login_date)
    end
  end
end
