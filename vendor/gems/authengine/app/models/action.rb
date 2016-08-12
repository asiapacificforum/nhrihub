class Action < ActiveRecord::Base
  belongs_to :controller

  has_many :action_roles, :dependent=>:destroy
  has_many :roles, :through => :action_roles

  # useractions are created in order to log actions performed by users, for recording in the log files
  has_many :useractions
  has_many :users, :through=>:useractions

  delegate :controller_name, :to=>:controller

  def self.not_enabled_for_developer
    where.not(:id => ActionRole.for_developer.pluck(:action_id))
  end

  def <=>(other)
    sort_field <=> other.sort_field
  end

  def sort_field
    [controller_name, action_name]
  end

  def self.list
    all_actions = Hash.new
    all(:include=>:controller).each{|a|
      all_actions[a.controller_name] ||= Hash.new
      all_actions[a.controller_name][a.action_name] = a.id
      }
    all_actions
  end

  def self.update_table_for(cont,action_names)
    remove_deleted_actions(cont, action_names)
    add_new_actions(cont, action_names)
  end

  def self.update_from_file(controller_file)
    current_actions = controller_file.controller_model.actions.map(&:action_name)
    new_actions = controller_file.actions
    remove_deleted_actions((current_actions - new_actions), controller_file.controller_model)
    add_new_actions((new_actions - current_actions), controller_file.controller_model)
  end

private
  def self.remove_deleted_actions(actions, controller)
    where(:action_name => actions, :controller_id => controller.id).destroy_all
  end

  def self.add_new_actions(actions, controller)
    actions.each { |action| create(:action_name => action, :controller_id => controller.id) }
  end
end
