class Admin::UserRolesController < ApplicationController
  # authengine_user_user_roles GET    /authengine/users/:user_id/user_roles/index(.:format)
  def index
    @user = User.find(params[:user_id])
    @all_roles = Role.order(:name).all
    @user_role = UserRole.new(:user_id => @user.id)
  end

  # create_authengine_user_user_roles POST   /authengine/users/:user_id/user_roles/create(.:format)
  # assign a new user_role to this user
  def create
    @user = User.find(params[:user_id])
    @user.user_roles.create(user_role_params)
    redirect_to admin_user_user_roles_path(@user)
  end

  def user_role_params
    params.require(:user_role).permit(:role_id)
  end

  # authengine_user_user_role DELETE /authengine/users/:user_id/user_roles/:id(.:format)
  # remove a user_role for this user
  def destroy
    user_role = UserRole.find_by_role_id_and_user_id(params[:id],params[:user_id])
    user_role.destroy
    redirect_to admin_user_user_roles_path(params[:user_id])
  end

  # edit_authengine_user_user_roles GET    /authengine/users/:user_id/user_roles/edit(.:format)
  # select a role to which current session will be downgraded
  def edit
    @user = User.find(params[:user_id])
    @user_role = UserRole.new(:user_id => @user.id)
    @roles = Role.lower_than(current_user.user_roles.map(&:role))
  end

  # update_authengine_user_user_roles PUT    /authengine/users/:user_id/user_roles/update(.:format)
  # session role is being downgraded for the logged-in user
  def update
    update_session_role(params[:user_role][:role_id])
    flash[:notice] = "Current session now has #{Role.find(params[:user_role][:role_id]).name} role"
    redirect_to new_authengine_session_path
  end

protected

  def update_session_role(role_id)
    session[:role].current_role_ids = []
    session[:role].create(role_id.to_i)
  end
end
