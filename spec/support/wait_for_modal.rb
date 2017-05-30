module WaitForModal
  def wait_for_modal_close
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until modal_has_closed?
    end
  end

  def wait_for_modal_open
    Timeout.timeout(Capybara.default_max_wait_time) do
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
