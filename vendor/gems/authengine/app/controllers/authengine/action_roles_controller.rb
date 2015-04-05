class Authengine::ActionRolesController < ApplicationController
  def index
    Controller.update_table # make sure the actions table includes all current controllers/actions, also enable developer access
    @actions = Action.
                 select('actions.id, actions.action_name, controllers.controller_name, actions.human_name').
                 joins(:controller).
                 reject{|a| a.action_name == "update" || a.action_name == "create"}.  # update & create have the same permissions as edit and new
                 sort_by{|a| [a[:controller_name],a.action_name]}
    @roles = Role.except_developer.order(:name)
    @allowed = []
    @roles.each{ |r| @allowed[r.id]= r.actions.map{ |a| a.id unless a.nil? } }
  end


  def update
    aa = ActionRole.all.group_by(&:role_id).inject({}){|hash,a| hash[a[0]]=a[1].collect(&:action_id); hash}
    params[:human_names].each do |action_id, human_name|
      Action.find(action_id.to_i).update_attribute(:human_name, human_name)
    end
    params[:permission].each do |role_id,permissions| # role is the role name, permissions is a hash of controller/action names
       role_id = role_id.to_i
       permissions.each do |action_id, val|
         action_id = action_id.to_i
         a = aa[role_id].nil? ? false : aa[role_id].include?(action_id) # because a new role, with no permissions granted, produces nil for aa[role_id.to_i]
         if val=="1" && !a # a newly-checked checkbox
           new = ActionRole.create(:role_id=>role_id,:action_id=>action_id)
           new.create_corresponding_create_and_update
         elsif val=="0" && a # a newly-unchecked checkbox
           to_be_deleted = ActionRole.find_by_role_id_and_action_id(role_id,action_id)
           to_be_deleted.delete_corresponding_create_and_update
           to_be_deleted.delete
         end
      end
    end

    redirect_to authengine_action_roles_path
  end

end
