require 'rspec/core/shared_context'

module StrategicPlanHelpers
  extend RSpec::Core::SharedContext
  def open_accordion_for_strategic_priority_one
    page.find("i#toggle").click
    sleep 0.3
  end

  def save_strategic_plan
    page.find('#save').click
    wait_for_ajax
  end

  def delete_plan
    page.all('.delete_strategic_plan')[0].click
  end

end
