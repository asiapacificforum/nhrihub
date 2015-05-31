require 'rails_helper'

describe "ControllerFile.for" do
  let(:controller_file){ ControllerFile.for(Controller.new(:controller_name =>"admin/users"))}
  it "should return the UsersController File object" do
    expect(controller_file).to be_a File
    expect(File.basename(controller_file)).to eq "users_controller.rb"
  end
end

describe "#modified?" do
  context "when modification dates are different" do
    let(:controller_file){ ControllerFile.for(Controller.new(:controller_name =>"admin/users", :last_modified => DateTime.parse("Tue, 26 May 2015 03:13:40 UTC +00:00")))}
    before do
      allow(File).to receive(:mtime).and_return(DateTime.parse("Tue, 26 May 2014 03:13:40 UTC +00:00"))
    end
    it "should return true" do
      expect(controller_file.modified?).to eq true
    end
  end

  context "when modification dates are the same" do
    let(:controller_file){ ControllerFile.for(Controller.new(:controller_name =>"admin/users", :last_modified => DateTime.parse("Tue, 26 May 2015 03:13:40 UTC +00:00")))}
    before do
      allow(File).to receive(:mtime).and_return(DateTime.parse("Tue, 26 May 2015 03:13:40 UTC +00:00"))
    end
    it "should return false" do
      expect(controller_file.modified?).to eq false
    end
  end
end

describe "actions" do
  let(:controller_file){ ControllerFile.for(Controller.new(:controller_name =>"admin/users"))}
  it "should include 'index'" do
    expect(controller_file.actions).to include("index")
  end
end

describe ".all" do
  it "should be an array of ControllerFile objects" do
    expect(ControllerFile.all).to be_a Array
    expect(ControllerFile.all.first).to be_a ControllerFile
  end
end

describe ".application_files" do
  it "should be an array of absolute file paths" do
    expect(ControllerFile.all_files).to be_a Array
    expect(ControllerFile.all_files).to include(Rails.root.join("app/controllers/admin_controller.rb"))
  end
end

describe ".engine_files" do
  it "should be an array of absolute file paths" do
    expect(ControllerFile.all_files).to be_a Array
    expect(ControllerFile.all_files).to include(Rails.root.join("vendor/gems/authengine/app/controllers/admin/users_controller.rb"))
  end
end

describe ".exists_for?" do
  context "when there is a controller file corresponding with the controller record" do
    before do
      @controller_model = Controller.create(:controller_name => 'admin/users')
    end

    it "should return true" do
      expect(ControllerFile.exists_for?(@controller_model)).to eq true
    end
  end

  context "when there is not a controller file corresponding with the controller record" do
    before do
      @controller_model = Controller.create(:controller_name => 'admin/foobar')
    end

    it "should return false" do
      expect(ControllerFile.exists_for?(@controller_model)).to eq false
    end
  end
end
