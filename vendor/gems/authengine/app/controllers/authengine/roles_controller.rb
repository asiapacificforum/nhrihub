class Authengine::RolesController < ApplicationController

  def index
    @all_roles = Role.order(:name).where("name != 'developer' ") # hide this role if it's there, it shouldn't be deleted
    @roles     = Role.equal_or_lower_than(current_user.roles)
  end

  def destroy
    @role = Role.find(params[:id])
    if @role.destroy # note: model callback applies
      redirect_to authengine_roles_path
    else
      flash[:error] = "Cannot remove a role if users are assigned.<br/>Please reassign or delete users."
      redirect_to authengine_roles_path
    end
  end

  def new
    @role  = Role.new
    @roles = Role.equal_or_lower_than(current_user.roles.to_a)
  end

  def create
    @role = Role.new(role_params)

    if @role.save
      redirect_to authengine_roles_path
    else
      @roles = Role.equal_or_lower_than(current_user.roles.to_a)
      render :action => "new"
    end
  end

  private
  def role_params
    params.require(:role).permit(:name, :parent_id)
  end

end
