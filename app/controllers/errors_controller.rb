class ErrorsController < ApplicationController
  skip_before_action :check_permissions, :check_browser

  before_action do
    @message = t('exceptions.default_message')
  end

  ActionDispatch::ExceptionWrapper.rescue_responses.values.each do |exception|
    define_method ( exception ) { render :generic_error, :status => Rack::Utils::SYMBOL_TO_STATUS_CODE[exception] }
  end

  # overrides method defined above
  # more text in this error, so handle the text in the internationalized views
  # not_found.en.haml, not_found.fr.haml etc
  def not_found
    render :status => 404
  end

  # overrides method defined above
  # this response is co-opted by the browser check
  # and therefore requires special handling
  def unprocessable_entity
    if (exception = request.env['action_dispatch.exception']).respond_to?(:message)
      @message = exception.message
    end
    render :generic_error, :status => 422
  end
end
