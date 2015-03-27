require 'rspec/core/shared_context'

module RolePresetsHelper
  extend RSpec::Core::SharedContext
  before do
    Role.create(:name => "intern")
    Role.create(:name => "temporary")
  end
end

