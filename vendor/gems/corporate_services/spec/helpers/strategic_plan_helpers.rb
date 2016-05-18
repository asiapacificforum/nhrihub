require 'rspec/core/shared_context'

module StrategicPlanHelpers
  extend RSpec::Core::SharedContext
  def open_accordion_for_strategic_priority_one
    page.find("i#toggle").click
    sleep 0.3
  end

  def resize_browser_window
    if page.driver.browser.respond_to?(:manage)
      page.driver.browser.manage.window.resize_to(1400,800) # b/c selenium driver doesn't seem to click when target is not in the view
    else
      #page.driver.resize(1600, 1200)
      page.driver.resize(1400, 800)
    end
  end
end
