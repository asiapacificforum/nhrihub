require 'authenticated_system'
require 'authorized_system'

class ApplicationController < ActionController::Base
  class ApplicationController::IncompatibleBrowserError < StandardError;
    def initialize
      message = I18n.t('exceptions.incompatible_browser_message')
      super(message)
    end
  end
  include AuthenticatedSystem
  include AuthorizedSystem
  rescue_from AuthenticatedSystem::XhrPermissionDenied, :with => :xhr_permission_denied
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :check_browser
  before_action :check_permissions, :log_exception_notifier_data

  around_action :with_locale
  before_action :set_title

private
  def check_browser
    two_factor_authentication_status = ENV.fetch('two_factor_authentication')
    two_factor_authentication_enabled = !(two_factor_authentication_status =~ /enabled/).nil?
    compatible_browser = (request.headers['User-Agent'] =~ /(Chrome|PhantomJS)/)
    if two_factor_authentication_enabled && !compatible_browser
      # this exception is rescued by the app configured in config/(env).rb
      # with the config.exceptions_app configuration
      raise ApplicationController::IncompatibleBrowserError.new
    end
  end

  def xhr_permission_denied
    # override this in controllers if this default response is not appropriate
    render :js => "flash.set('error_message', '#{t('error_messages.not_permitted')}');flash.notify();", :status => 401
  end

  def no_method_error(exception)
    render :template => "/errors/404.html.haml", :status => 404
  end

  def log_exception_notifier_data
    if current_user
      request.env["exception_notifier.exception_data"] = {
        :user => current_user.first_last_name,
        :email => current_user.email
      }
    end
  end

  # @title must be set in the specific
  # controller if title has some dynamic content
  # otherwise it's set here to be either the same
  # as the heading or else the translation in the
  # locale xx.yml file
  def set_title
    if t('.page_title').match /translation missing/
      # yml file doesn't have an entry for the .title key
      # so use the heading value
      @title = t('.heading') 
    else
      @title = t('.page_title')
    end
  end

  def with_locale
    I18n.with_locale(params[:locale]) { yield }
  rescue => e
    logger.error e.message
    logger.error e.backtrace.join("\n")
  end

  def default_url_options(options = {})
    options.merge({ locale: I18n.locale })
  end
  
end
