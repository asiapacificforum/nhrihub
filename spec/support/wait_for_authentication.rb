# thank you Thoughtbot!
# https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
# modified for the two-factor authentication delays
module WaitForAuthentication
  def wait_for_authentication
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_authentication?
    end
  end

  def finished_authentication?
    # detect when the second-step of the authentication protocol has loaded the target page
    page.evaluate_script("typeof(authentication_pending)") == 'undefined'
  end

end

RSpec.configure do |config|
  config.include WaitForAuthentication, type: :feature
end
