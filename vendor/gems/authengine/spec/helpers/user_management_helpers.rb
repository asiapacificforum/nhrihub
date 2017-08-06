require 'rspec/core/shared_context'

module UserManagementHelpers
  extend RSpec::Core::SharedContext

  def user_record_for(user)
    page.find(:xpath, "//tr[contains(td[2]/text(),'#{user.lastName}')]")
  end

  def norman_normal_to_be_in_the_database
    User.where(:firstName => "Norman", :lastName => "Normal").exists?
  end

  def norman_normal_account_is_activated 
    User.where(:firstName => "Norman", :lastName => "Normal").first.active?
  end

  def email_activation_link
    link_from_last_email
  end

  def new_password_activation_link
    link_from_last_email
  end

  def replacement_token_registration_link
    link_from_last_email
  end

  def signup
    page.find('.btn#sign_up').click
    wait_for_ajax
  end

  def submit_button
    page.find('.btn#submit')
  end

  def register_button
    page.find('.btn#register')
  end

private
  def link_from_last_email
    visit("/") # else there's no current_session yet from which to derive the url
    url = find_url_in_email
    host, port = get_url_params
    local_url = url.gsub(/^http:\/\/[^\/]*/,"#{host}:#{port}")
    "http://"+local_url
  end

  def find_url_in_email
    email = ActionMailer::Base.deliveries.last
    Nokogiri::HTML(email.body.to_s).xpath(".//p/a").attr('href').value
  end

  def get_url_params
    if Capybara.current_session.server # real browser
      host = Capybara.current_session.server.host
      port = Capybara.current_session.server.port
    else # capybara-webkit
      host = Capybara.current_session.driver.request.host
      port = Capybara.current_session.driver.request.port
    end
    [host, port]
  end

end
