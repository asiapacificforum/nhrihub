require 'rspec/core/shared_context'

module StrategicPlanHelpers
  extend RSpec::Core::SharedContext
  def open_accordion_for_strategic_priority_one
    page.find("i#toggle").click
    wait_for_accordion(".strategic_priority_content")
  end

end
