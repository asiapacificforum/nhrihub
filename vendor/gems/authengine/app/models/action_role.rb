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

  def self.update_permissions(params)
    aa = Role.all_with_permitted_action_ids
    params.each do |role_id,permissions| # role is the role name, permissions is a hash of controller/action names
       role_id = role_id.to_i
       permissions.each do |action_id, val|
         action_id = action_id.to_i
         a = aa[role_id].include?(action_id)
         if val=="1" && !a # a newly-checked checkbox
           new = ActionRole.create(:role_id=>role_id,:action_id=>action_id)
           new.create_corresponding_create_and_update
         elsif val=="0" && a # a newly-unchecked checkbox
           to_be_deleted = ActionRole.find_by_role_id_and_action_id(role_id,action_id)
           to_be_deleted.delete_corresponding_create_and_update
           to_be_deleted.destroy
         end
      end
    end
  end

  def create_corresponding_create_and_update
    create_corresponding(paired_method(action_name)) if paired_method(action_name)
  end

  def delete_corresponding_create_and_update
    delete_corresponding(paired_method(action_name)) if paired_method(action_name)
  end

  private
  def paired_method(method)
    return "create" if method=="new"
    return "update" if method=="edit"
  end

  def action_name
    @action ||= Action.find(action_id)
    @action_name = @action.action_name
  end

  def create_corresponding(paired_method)
    ActionRole.create(:action_id => corresponding_action_id(paired_method), :role_id => role_id)
  end

  def delete_corresponding(paired_method)
    ActionRole.delete_all(:action_id => corresponding_action_id(paired_method), :role_id => role_id)
  end

  def corresponding_action_id(method)
    Action.where(:controller_id => @action.controller_id, :action_name => method).first.id
  end
end
