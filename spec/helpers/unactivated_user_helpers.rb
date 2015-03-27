require 'rspec/core/shared_context'

module UnactivatedUserHelpers
  extend RSpec::Core::SharedContext
  before do
    user = User.create(
                :email => Faker::Internet.email,
                :enabled => true,
                :firstName => Faker::Name.first_name,
                :lastName => Faker::Name.last_name)
    role = Role.create(:name => 'intern')
    UserRole.create(:user_id => user.id, :role_id => role.id)
  end
end
