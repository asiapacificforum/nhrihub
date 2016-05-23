require 'rspec/core/shared_context'

module ComplaintsBehaviourHelpers
  extend RSpec::Core::SharedContext
  def first_complaint
    page.all('#complaints .complaint')[0]
  end
end
