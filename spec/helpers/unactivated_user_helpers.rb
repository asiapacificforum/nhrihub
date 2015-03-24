require 'rspec/core/shared_context'

module UnactivatedUserHelpers
  extend RSpec::Core::SharedContext
  before do
    user = create_user
  end

private
  def create_user
    user = User.create(
                :email => 'user@example.com',
                :enabled => true,
                :firstName => 'A',
                :lastName => 'User')
  end
end
