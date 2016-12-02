class ActionRole < ActiveRecord::Base
  belongs_to :role, :touch => true
  belongs_to :action

  scope :for_developer, -> { joins(:role).merge(Role.developer) }

  # this is the key database lookup for checking permissions
  # returns true if there is at least one of the passed-in role ids
  # which explicitly permits (i.e. the role has action_role associations)
  # the specified controller and action
  def self.permits_access_for(controller, action, role_ids)
    joins([:role, :action => :controller ]).
      where("roles.id" => role_ids).
            where("actions.action_name" => action).
            where("controllers.controller_name" => controller).
            exists?
  end

  def self.assign_developer_access
    dev_role = Role.find_or_create_by(:name => 'developer')
    Action.not_enabled_for_developer.each do |action|
      create(:action => action, :role => dev_role)
    end
  end

  def self.bootstrap_access_for(role)
    Action.all.each do |a|
      find_or_create_by(:action_id => a.id, :role_id => role.id)
    end
  end

  def create_corresponding_create_and_update
    case action_name
    when "new"
      create_create
    when "edit"
      create_update
    end
  end

  def delete_corresponding_create_and_update
    case action_name
    when "new"
      delete_create
    when "edit"
      delete_update
    end
  end

  private
  def action_name
    @action ||= Action.find(action_id)
    @action_name = @action.action_name
  end

  def create_create
    corresponding_action = Action.where(:controller_id => @action.controller_id, :action_name => "create").first
    ActionRole.create(:action_id => corresponding_action.id, :role_id => role_id)
  end

  def create_update
    corresponding_action = Action.where(:controller_id => @action.controller_id, :action_name => "update").first
    ActionRole.create(:action_id => corresponding_action.id, :role_id => role_id)
  end

  def delete_create
    corresponding_action = Action.where(:controller_id => @action.controller_id, :action_name => "create").first
    ActionRole.where(:action_id => corresponding_action.id, :role_id => role_id).delete_all
  end

  def delete_update
    corresponding_action = Action.where(:controller_id => @action.controller_id, :action_name => "update").first
    ActionRole.where(:action_id => corresponding_action.id, :role_id => role_id).delete_all
  end
end
