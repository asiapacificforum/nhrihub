module WaitForModal
  def wait_for_modal_close
    earlier_version = Capybara::VERSION == "2.5.0.dev" || Capybara::VERSION.to_f <= 2.4
    default_wait_time = earlier_version ? :default_wait_time : :default_max_wait_time
    Timeout.timeout(Capybara.send(:default_wait_time)) do
      loop until modal_has_closed?
    end
  end

  def wait_for_modal_open
    earlier_version = Capybara::VERSION == "2.5.0.dev" || Capybara::VERSION.to_f <= 2.4
    default_wait_time = earlier_version ? :default_wait_time : :default_max_wait_time
    Timeout.timeout(Capybara.send(:default_wait_time)) do
      loop until modal_is_open?
    end
  end

  def modal_has_closed?
    page.evaluate_script("$('.modal-backdrop').length").zero?
  end

  def modal_is_open?
    page.evaluate_script("$('.modal.fade.in').length") == 1
  end
end

RSpec.configure do |config|
  config.include WaitForModal, type: :feature
end
