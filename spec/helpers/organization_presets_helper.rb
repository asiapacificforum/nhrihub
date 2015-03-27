require 'rspec/core/shared_context'

module OrganizationPresetsHelper
  extend RSpec::Core::SharedContext
  before do
    Organization.create(:name => "Government of Illyria")
  end
end

