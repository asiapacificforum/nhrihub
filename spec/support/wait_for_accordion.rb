# thank you Thoughtbot!
# https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
module WaitForAccordion
  def wait_for_accordion(accordion_element)
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until accordion_transition_finished?(accordion_element)
    end
  end

  def accordion_transition_finished?(accordion_element)
    !page.evaluate_script("$('#{accordion_element}').hasClass('collapsing')")
  end

end

RSpec.configure do |config|
  config.include WaitForAccordion, type: :feature
end
