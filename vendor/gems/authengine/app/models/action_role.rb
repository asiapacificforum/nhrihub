class ActionRole < ActiveRecord::Base
  belongs_to :role
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
    dev_role = Role.developer.first
    Action.not_enabled_for_developer.each do |action|
      create(:action => action, :role => dev_role)
    end
  end

  def self.bootstrap_access_for(role)
    Action.all.each do |a|
      find_or_create_by(:action_id => a.id, :role_id => role.id)
    end
  end
end
