require 'rspec/core/shared_context'

module UserManagementHelpers
  extend RSpec::Core::SharedContext

  def norman_normal_to_be_in_the_database
    User.where(:firstName => "Norman", :lastName => "Normal").exists?
  end

  def norman_normal_account_is_activated 
    User.where(:firstName => "Norman", :lastName => "Normal").first.active?
  end

  def email_activation_link
    visit("/") # else there's no current_session yet from which to derive the url
    email = ActionMailer::Base.deliveries.last
    url = Nokogiri::HTML(email.body.to_s).xpath(".//p/a").attr('href').value
    if Capybara.current_session.server # real browser
      host = Capybara.current_session.server.host
      port = Capybara.current_session.server.port
    else # capybara-webkit
      host = Capybara.current_session.driver.request.host
      port = Capybara.current_session.driver.request.port
    end
    local_url = url.gsub(/^http:\/\/[^\/]*/,"#{host}:#{port}")
    "http://"+local_url
  end

  def new_password_activation_link
    email_activation_link
  end

  def signup
    page.find('.btn#sign_up').click
    wait_for_ajax
  end
end
