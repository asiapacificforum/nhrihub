require 'rspec/core/shared_context'

module PerformanceIndicatorHelpers
  extend RSpec::Core::SharedContext
  def remove_first_indicator
    page.all('.selected_performance_indicator .remove')[0]
  end

  def remove_last_indicator
    page.all('.selected_performance_indicator .remove')[-1]
  end

  # it's prepopulated with the last 3 performance indicators, so adding the last again is a duplicate
  def add_a_performance_indicator
    select_performance_indicators.click
    page.all("li.performance_indicator a").last.click
    PerformanceIndicator.all.to_a.last
  end

  # it's prepopulated with the last 3 performance indicators, so adding the first is unique
  def add_a_unique_performance_indicator
    select_performance_indicators.click
    page.all("li.performance_indicator a").first.click
    PerformanceIndicator.all.to_a.first
  end

  def select_first_performance_indicator
    sleep(0.1)
    page.all("li.performance_indicator a").first.click
  end

end
