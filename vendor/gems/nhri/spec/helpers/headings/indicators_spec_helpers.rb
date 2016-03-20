require 'rspec/core/shared_context'

module IndicatorsSpecHelpers
  extend RSpec::Core::SharedContext

  def delete_indicator
    page.all('.indicator .delete_indicator')[0]
  end

  def add_indicator
    #page.driver.resize_window_to(page.driver.current_window_handle,1280,1024) if page.driver.is_a? Capybara::Selenium::Driver
    #page.driver.resize_window(2224,1024) if page.driver.is_a? Capybara::Poltergeist::Driver
    page.all('.new_indicator').first.click
    sleep(0.3)
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
