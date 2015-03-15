require File.expand_path("../../spec_helper", __FILE__)


describe 'permits_access_for class method' do
  subject{ access_permitted }
  let(:role){ Role.create(:name => 'chief') }
  let(:controller){ Controller.create(:controller_name => 'traveller') }
  let(:action){ Action.create(:action_name => 'travel', :controller_id => controller.id) }
  before { ActionRole.create(:action_id => action.id, :role_id => role.id) }

  context "access based on user's permitted roles" do
    before(:each) do
      @user = FactoryGirl.create(:user, :login => 'just_me')
      UserRole.create(:role_id => role.id, :user_id => @user.id)
    end

    let(:access_permitted){ ActionRole.permits_access_for(controller.controller_name, action.action_name, @user.roles(true).map(&:id)) }

    context "user accesses a permitted action" do
      it { should == true }
    end

    context "user accesses an action not assigned to the user's role" do
      before { action.action_name = "some_action" }
      it { should == false }
    end

    context "user has no roles assigned" do
      before { @user = FactoryGirl.create(:user, :login => 'another_person') }
      it { should == false }
    end

    context "user has a role that does not permit access to the requested action" do
      before {
        UserRole.delete_all
        UserRole.create(:role_id => 555, :user_id => @user.id)
      }
      it { should == false }
    end

    context "user's role does not permit access to the requested action" do
      before {
        ActionRole.delete_all
        ActionRole.create(:action_id => action.id, :role_id => 555)
      }
      it { should == false }
    end
  end

  context "access based on role id" do
    let(:another_role){ Role.create(:name => 'minion') }
    let(:user){ FactoryGirl.create(:user, :login => 'just_me') }
    let(:access_permitted){ ActionRole.permits_access_for(controller.controller_name, action.action_name, @role_ids) }

    context "should permit when one of the passed-in roles has an action_role that links to the passed in controller/action" do
      before {@role_ids = [role.id]}
      it { should == true }
    end

    context "should not permit when none of the passed-in roles has an action role for the passed-in controller/action" do
      before { @role_ids = [another_role.id] }
      it { should == false }
    end
  end
end
