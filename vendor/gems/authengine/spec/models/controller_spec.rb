require 'rails_helper'

describe "creation of new Controller model when a ControllerFile is added" do
  context "when there is a file without a controller record" do
    before do
      @file = Rails.root.join("app/controllers/testfile_controller.rb")
      file = File.open(@file, "w+")
      file.write "class TestfileController < ApplicationController; def index; end; def show; end; end"
      file.close
      @controller_file = ControllerFile.new(@file)
    end

    after do
      FileUtils.rm(@file)
    end

    it "should be created" do
      expect(Controller.where(:controller_name => @controller_file.model_string).count).to eq 1
    end
  end

  context "when there is a file and a corresponding controller record" do
    before do
      @file = Rails.root.join("vendor/gems/authengine/app/controllers/admin/users_controller.rb")
      Controller.create(:controller_name => "admin/users")
      @controller_file = ControllerFile.new(@file)
    end

    it "should not create another Controller model" do
      expect(Controller.where(:controller_name => @controller_file.model_string).count).to eq 1
    end
  end
end

describe "delete obsolete controllers" 

describe "create_from_file" do
  before do
    @file = Rails.root.join("app/controllers/testfile_controller.rb")
    file = File.open(@file, "w+")
    file.write "class TestfileController < ApplicationController; def index; end; end"
    file.close
    @controller_file = ControllerFile.new(@file)
    Controller.create_from_file(@controller_file)
  end

  after do
    FileUtils.rm(@file)
  end

  it "should create the controller record" do
    expect(Controller.exists?(:controller_name => "testfile")).to be true
    expect(Action.exists?(:action_name => "index", :controller_id => Controller.first.id)).to be true
  end
end

describe "update_from_file" do
  context "when a method is added" do
    before do
      @file = Rails.root.join("app/controllers/testfile_controller.rb")
      file = File.open(@file, "w+")
      file.write "class TestfileController < ApplicationController; def index; end; end"
      file.close
      load @file
      @controller_file = ControllerFile.new(@file)
      file = File.open(@file, "w+")
      file.write "class TestfileController < ApplicationController; def index; end; def show; end; end"
      file.close
      load @file
      Controller.first.update_from_file(@controller_file)
    end

    after do
      FileUtils.rm(@file)
    end

    it "should update the controller record" do
      expect(Action.exists?(:action_name => "show", :controller_id => Controller.first.id)).to be true
    end
  end

  context "when a method is removed" do
    before do
      @file = Rails.root.join("app/controllers/testfile_controller.rb")
      file = File.open(@file, "w+")
      file.write "class TestfileController < ApplicationController; def index; end; def show; end; end"
      file.close
      load @file
      @controller_file = ControllerFile.new(@file)
      file = File.open(@file, "w+")
      file.write "class TestfileController < ApplicationController; def index; end; end"
      file.close
      load @file
      TestfileController.send(:undef_method,"show") # b/c reloading the file doesn't undefine the existing methods!
      Controller.first.update_from_file(@controller_file)
    end

    after do
      FileUtils.rm(@file)
    end

    it "should update the controller record" do
      expect(Action.exists?(:action_name => "show", :controller_id => Controller.first.id)).to be false
    end
  end
end

describe "delete_obsolete_controllers" do
  before do
    @file = Rails.root.join("app/controllers/testfile_controller.rb")
    file = File.open(@file, "w+")
    file.write "class TestfileController < ApplicationController; def index; end; def show; end; end"
    file.close
    @controller_file = ControllerFile.new(@file)
    FileUtils.rm(@file)
  end

  it "controller model should be removed" do
    expect{Controller.delete_obsolete_controllers}.to change{Controller.count}.from(1).to(0)
  end
end
