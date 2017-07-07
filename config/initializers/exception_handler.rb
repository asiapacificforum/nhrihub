Rails.application.configure do
  config.exceptions_app = ->(env) do
    exception = env['action_dispatch.exception']
    rescue_action = ActionDispatch::ExceptionWrapper.rescue_responses[exception.class.name]
    ErrorsController.action(rescue_action).call(env)
  end
end
