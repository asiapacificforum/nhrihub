class ControllerFile < File
  CONTROLLERS_DIR = "#{Rails.root.to_s}/app/controllers"
  cattr_accessor :controllers
  attr_accessor :controller_model

  # all controller files in the app, as ControllerFile instances
  def self.all
    all_files.map{|file| new(file,nil)}
  end

  def self.all_files
    application_files + engine_files
  end

  # e.g. Pathname "~/app/controllers/admin_controller.rb"
  def self.application_files
    Pathname.
      glob(CONTROLLERS_DIR+"**/*_controller.rb").
      reject{|p| p.to_s =~ /application/ }
  end

  # e.g. "~/vendor/gems/authengine/app/controllers/admin/users_controller.rb"
  def self.engine_files
    engine_controller_paths.
      collect{|path| Pathname.glob(path+"**/*_controller.rb")}.
      flatten
  end

  # e.g. "~/../app/controllers"
  def self.engine_controller_paths
    Rails::Engine.subclasses.collect { |engine|
      engine.config.eager_load_paths.detect{|p| p=~/controller/}
    }.flatten.compact.map{|p| Pathname(p)}
  end

  def self.for(controller_model)
    @controller_model = controller_model
    controller_path = ControllerFile.all_files.detect do |path|
      path.to_s.match(/#{controller_model.controller_name}_controller.rb$/)
    end
    new(controller_path, controller_model) if controller_path
  end

  # true if a file exists for a controller_model in the database controllers table
  def self.exists_for?(controller_model)
    all_files.
      map{|p| p.to_s.match(/.*app\/controllers\/(.*)_controller.rb/)[1]}.
      include?(controller_model.controller_name)
  end

  def last_modified_in_model
    controller_model.last_modified
  end

  def initialize(path, controller_model=nil)
    super(path)
    @controller_model = controller_model || Controller.find_or_create_from_file(self)
  end

  # a file is declared to be modified if it's either older or newer than the last_modified date
  # this triggers re-parsing the actions in the file whether it's older or newer
  # and so responds both to the file being edited and also the database being restored
  # from an older version.
  # Only by converting to string could I persuade two apparently equal DateTime objects to match!
  def modified?
    file_modification_time.to_s != last_modified_in_model.getutc.to_datetime.to_s
  end

  def file_modification_time
    File.mtime(self).getutc.to_datetime
  end

  def actions
    controller_object.public_instance_methods(false).map(&:to_s)
  end

  # e.g. admin/users
  def model_string
    File.path(self).match(/^.*controllers\/(.*)_controller\.rb/)[1]
  end

  def controller_name
    (model_string+"_controller").classify
  end

  # e.g. Admin::UsersController
  def controller_object
    controller_name.constantize
  end

end
