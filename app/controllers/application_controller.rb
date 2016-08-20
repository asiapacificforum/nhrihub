class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :check_permissions, :log_exception_notifier_data

  around_action :with_locale
  before_action :set_title

private
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
