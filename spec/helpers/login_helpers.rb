require 'rspec/core/shared_context'
require 'ie_remote_detector'

module RegisteredUserHelper
  extend RSpec::Core::SharedContext
  before do
    admin = create_user('admin')
    @user = admin
    assign_permissions(admin, 'admin', admin_roles)
    staff = create_user('staff')
    assign_permissions(staff, 'staff', staff_roles)
  end

  def remove_user_two_factor_authentication_credentials(user)
    user = User.where(:login => user).first
    user.update_attributes(:public_key => nil, :public_key_handle => nil)
  end

  def login_button
    page.find('.btn#sign_up')
  end

  def configure_keystore
    js = <<-JS.squish
      record = {"626f6775735f31343732303131363138353438":{ appId : "https://oodb.railsplayground.net", counter : 26, generated : "2016-08-24T04:11:36.812Z", keyHandle : "626f6775735f31343732303131363138353438", private : "219c8b4c622a837e981d7aef8ca7fe360d662203b051d3e430705c4e84289562", public : "04c43e43bc88b589cd610a735c99b412ef9eb1f2039773e4c500cd2bffdfd081750b26d9c85632d95ace37c778ae2577856633949427fe1447c37996146f4d8f73"}};
      replaceKeyStore (record);
    JS
    page.execute_script(js)
  end

private

  def create_user(login)
    # see http://www.relishapp.com/rspec/rspec-mocks/v/3-5/docs/working-with-legacy-code/any-instance
    #allow_any_instance_of(User).to receive(:authenticated?).and_return(true)
    #allow_any_instance_of(AuthorizedSystem).to receive(:check_permissions).and_return(true)
    #allow_any_instance_of(ApplicationHelper).to receive(:current_user_permitted?).and_return(true)

    user = User.create(:login => login,
                :email => Faker::Internet.email,
                :enabled => true,
                :firstName => Faker::Name.first_name,
                :lastName => Faker::Name.last_name,
                :organization => Organization.first,
                :public_key => "BMQ+Q7yItYnNYQpzXJm0Eu+esfIDl3PkxQDNK//f0IF1CybZyFYy2VrON8d4riV3hWYzlJQn/hRHw3mWFG9Nj3M=",
                :public_key_handle => "Ym9ndXNfMTQ3MjAxMTYxODU0OA")
    user.update_attribute(:salt, '1641b615ad281759adf85cd5fbf17fcb7a3f7e87')
    user.update_attribute(:activation_code, '9bb0db48971821563788e316b1fdd53dd99bc8ff')
    user.update_attribute(:activated_at, DateTime.new(2011,1,1))
    user.update_attribute(:crypted_password, '660030f1be7289571b0467b9195ff39471c60651')
    user
  end

  def assign_permissions(user, role, actions)
    role = Role.create(:name => role)
    Controller.update_table
    actions.each { |a| role.actions << a  }
    user.roles << role
    user.save
  end

  def admin_roles
    Action.all
  end

  def staff_roles
    Action.
      all.
      reject{|a|
        a.controller_name =~ /authengine/ && 
          !(a.controller_name =~ /sessions/ && (a.action_name == "new" || a.action_name == "destroy")) # login/logout
      }.
      reject{|a| a.controller_name =~ /admin/}
  end
end

module LoggedInEnAdminUserHelper
  extend RSpec::Core::SharedContext
  include RegisteredUserHelper
  include IERemoteDetector
  before do
    visit "/en"
    configure_keystore
    #unless ie_remote?(page) # IE doesn't delete cookies and terminate session between scenarios, so no need for login
    if page.has_selector?("h1", :text => "Please log in")
      fill_in "User name", :with => "admin"
      fill_in "Password", :with => "password"
      login_button.click # triggers ajax request for challenge, THEN form submit
      wait_for_authentication
    end
    resize_browser_window
  end
end

module LoggedInFrAdminUserHelper
  extend RSpec::Core::SharedContext
  include RegisteredUserHelper
  include IERemoteDetector
  before do
    visit "/fr"
    configure_keystore
    if page.has_selector?("h1", :text => "S'il vous plaît connecter")
      fill_in "Nom d'usilateur", :with => "admin"
      fill_in "Mot de pass", :with => "password"
      login_button.click
      wait_for_authentication
    end
  end
end
