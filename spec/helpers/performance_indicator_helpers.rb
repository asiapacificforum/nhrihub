require 'rspec/core/shared_context'

module PerformanceIndicatorHelpers
  extend RSpec::Core::SharedContext
  def remove_first_indicator
    page.all('.selected_performance_indicator .remove')[0]
  end

  def remove_indicator(pi)
    page.find('.selected_performance_indicator', :text => pi.indexed_description).find('.remove').click
    wait_for_ajax
  end

  def add_a_duplicate_performance_indicator
    select_performance_indicators.click unless page.evaluate_script("$('.performance_indicator_select:visible').hasClass('open')") == true
    dupe = @model.first.performance_indicators.first
    page.find("li.performance_indicator a", :text => dupe.indexed_description).click
    dupe
  end

  def add_a_unique_performance_indicator
    select_performance_indicators.click unless page.evaluate_script("$('.performance_indicator_select:visible').hasClass('open')") == true
    current_pis = @model.first.performance_indicators.map(&:indexed_description)
    unique_pi_selector = page.all("li.performance_indicator a").reject{|pi| current_pis.include? pi.text}.first
    unique_pi_selector.click
    PerformanceIndicator.where(:index => unique_pi_selector.text.split(' ')[0]).first
  end

end
