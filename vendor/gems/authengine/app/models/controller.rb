# the table is managed so as to make it mirror the file system
# in order to be able to store in the
# database a last_modified attribute for a file, in order to
# know whether the actions table is up to date for this controller
# or should be regenerated from the file contents
class Controller < ActiveRecord::Base
  has_many :actions, :dependent=>:destroy

  def modified?
    file.modified?
  end

  def file
    ControllerFile.new(nil, self)
  end

  # updates the controllers table so that it contains a record for each controller file
  # in the /app/controllers directory and in all app/controllers directories of all engines
  def self.update_table
    ControllerFile.all.each do |controller_file|
      # file was modified since db was updated, so read the actions from the file, and add/delete as necessary
      controller_file.controller_model.update_from_file(controller_file) if controller_file.modified?
    end
    ActionRole.assign_developer_access
    delete_obsolete_controllers
  end

  def update_from_file(controller_file)
    Action.update_from_file(controller_file)
    # modify the last_modified date of the controller record to match the actual file
    update_attribute(:last_modified,controller_file.file_modification_time)
  end

  def self.delete_obsolete_controllers
    # delete any records in the controllers table for which there's no xx_controller.rb file... it must've been deleted
    Controller.all.each do |controller|
      controller.destroy if !ControllerFile.exists_for?(controller)
    end
  end

  def self.create_from_file(controller_file)
    new_controller = new(:controller_name=>controller_file.model_string, :last_modified=>Date.today) # add controller to controllers table as there's not a record corresponding with the file
    new_controller.actions << controller_file.actions.map { |a| Action.new(:action_name=>a) }# when a new controller is added, its actions must be added to the actions.file
    new_controller.save
    new_controller
  end

  def self.find_or_create_from_file(controller_file)
    where(:controller_name => controller_file.model_string).first ||
      create_from_file(controller_file)
  end

end
