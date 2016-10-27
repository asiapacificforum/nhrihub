require 'rspec/core/shared_context'

module IndicatorsSpecHelpers
  extend RSpec::Core::SharedContext

  def delete_indicator
    page.all('.indicator .delete_indicator')[0]
  end

  def add_all_attribute_indicator
    page.all('.all_attribute_indicators .new_indicator')[0].click
  end

  def add_single_attribute_indicator
    page.all('.single_attribute_indicators .new_indicator')[0].click
  end

  def save_indicator
    page.find('#save_indicator')
  end

  def cancel_add
    page.find('button.close').click
  end

  def edit_first_indicator
    page.all('.edit_indicator').first.click
    sleep(0.2) # css transition
  end
end
