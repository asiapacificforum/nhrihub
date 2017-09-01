require_relative './example_dot_com_server'

module ExampleDotCom
  def example_dot_com
    example_dot_com_server = ExampleDotComServer.boot
    "http://#{example_dot_com_server.host}:#{example_dot_com_server.port}/something"
  end
end

RSpec.configure do |config|
  config.include ExampleDotCom, type: :feature
end
