require 'sinatra/base'

# thank you Thoughtbot!
# https://robots.thoughtbot.com/using-capybara-to-test-javascript-that-makes-http
class ExampleDotComServer < Sinatra::Base
  def self.boot
    instance = new
    Capybara::Server.new(instance).tap { |server| server.boot }
  end

  get '/something' do
    "<h1>Example Domain</h1>"
  end
end
