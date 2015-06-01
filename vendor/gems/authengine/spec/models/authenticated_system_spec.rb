require 'rails_helper'
require Authengine::Engine.root.join('app', 'models', 'authenticated_system').to_s
require Authengine::Engine.root.join('app', 'models', 'authorized_system').to_s

class FoobarController < ApplicationController
  attr_accessor :flash

  def initialize
    @flash = {}
  end

  def extension; end

  def headers
    {}
  end


  def render(something); end

  include AuthenticatedSystem
  include AuthorizedSystem
end

# TODO need to make these tests work with rspec mocks and rails 4
#describe "AuthenticatedSystem redirection when permission is denied" do

  #it "redirects to the login page when user came from another site" do
    #ext = double
    #allow(ext).to receive(:html).once.and_yield
    #allow(ext).to receive(:xml).once.and_yield
    #allow(FoobarController).to receive(:respond_to).once.and_yield(ext)
    #allow_any_instance_of(FoobarController).to receive(:session).and_return({:refer_to => nil})
    #env = double("env",
               #:env => {"HTTP_REFERER" => "http://same_domain.com/some_page"},
               #:fullpath => "http://same_domain.com/some_page")
    #allow_any_instance_of(FoobarController).to receive(:request).and_return(env)
    #allow_any_instance_of(FoobarController).to receive(:root_path).and_return("root_path")
    #allow(FoobarController).to receive(:domain_name).and_return("http://same_domain.com/some_page")
    #allow_any_instance_of(FoobarController).to receive("redirect_to").once.with("root_path")

    #FoobarController.new.send('permission_denied')
  #end

  #it "redirects to the login page if the http referer is not present" do
    #ext = flexmock('extension')
    #expect(ext).to receive(:html).once.and_yield
    #expect(ext).to receive(:xml).once.and_yield
    #flexmock(FoobarController).new_instances do |f|
      #expect(f).to receive(:respond_to).once.and_yield(ext)
      #expect(f).to receive(:session).and_return({:refer_to => nil})
      #env = flexmock("env",
                     #:env => {"HTTP_REFERER" => nil},
                     #:fullpath => "http://same_domain.com/some_page")
      #expect(f).to receive(:request).and_return(env)
      #expect(f).to receive(:root_path).and_return("root_path")
      #expect(f).to receive(:domain_name).and_return("http://same_domain.com/some_page")
      #expect(f).to receive("redirect_to").once.with("root_path")
    #end

    #FoobarController.new.send('permission_denied')
  #end

  #context "when user came from this site" do
    #it "redirects to the previous page if it's not the same as the requested page" do
      #ext = flexmock('extension')
      #expect(ext).to receive(:html).once.and_yield
      #expect(ext).to receive(:xml).once.and_yield
      #flexmock(FoobarController).new_instances do |f|
        #expect(f).to receive(:respond_to).once.and_yield(ext)
        #expect(f).to receive(:session).and_return({:refer_to => nil})
        #env = flexmock("env",
                       #:env => {"HTTP_REFERER" => "http://same_domain.com/different_page"},
                       #:fullpath => "http://same_domain.com/some_page")
        #expect(f).to receive(:request).and_return(env)
        #expect(f).to receive(:root_path).and_return("root_path")
        #expect(f).to receive(:domain_name).and_return("http://same_domain.com/some_page")
        #expect(f).to receive("redirect_to").once.with("http://same_domain.com/different_page")
      #end

      #FoobarController.new.send('permission_denied')
    #end

    #it "redirects to the login page if the previous page is the same as the requested page" do
      #ext = flexmock('extension')
      #expect(ext).to receive(:html).once.and_yield
      #expect(ext).to receive(:xml).once.and_yield
      #flexmock(FoobarController).new_instances do |f|
        #expect(f).to receive(:respond_to).once.and_yield(ext)
        #expect(f).to receive(:session).and_return({:refer_to => nil})
        #env = flexmock("env",
                       #:env => {"HTTP_REFERER" => "http://same_domain.com/some_page"},
                       #:fullpath => "http://same_domain.com/some_page")
        #expect(f).to receive(:request).and_return(env)
        #expect(f).to receive(:root_path).and_return("root_path")
        #expect(f).to receive("redirect_to").once.with("root_path")
      #end

      #FoobarController.new.send('permission_denied')
    #end
  #end
#end
