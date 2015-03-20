class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_action :with_locale
  before_action :set_title

  private

  def set_title
    @title = t('.title')
  end

  def with_locale
    I18n.with_locale(params[:locale]) { yield }
  end

  def default_url_options(options = {})
    { locale: I18n.locale }
  end
  
end
