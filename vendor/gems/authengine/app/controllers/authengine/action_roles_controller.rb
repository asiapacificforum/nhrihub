class Authengine::ActionRolesController < ApplicationController
  def index
    Controller.update_table # make sure the actions table includes all current controllers/actions, also enable developer access
    @actions = Action.
                 select('actions.id, actions.action_name, controllers.controller_name, actions.human_name').
                 joins(:controller).
                 sort_by{|a| [a[:controller_name],a.action_name]}
    @roles = Role.except_developer.order(:name).select(:name, :id)
    @allowed= Role.all_with_permitted_action_ids
  end


  def update
    Action.update_human_names(params[:human_names])
    ActionRole.update_permissions(params[:permission])
    redirect_to authengine_action_roles_path
  end

end
