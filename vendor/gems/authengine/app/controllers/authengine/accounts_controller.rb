class Authengine::AccountsController < ApplicationController

  # because a user cannot login until the account is activated
  skip_before_action :check_permissions, :only => [:show]

  # Activate action
  def show
    @user = User.find_with_activation_code(params[:activation_code])
    session[:activation_code] = params[:activation_code]
    redirect_to signup_admin_user_path(@user) # admin/users#signup
  rescue User::BlankActivationCode
    flash[:notice] =t('admin.users.activate.argument_error')
    redirect_to login_path
  rescue User::ActivationCodeNotFound # wrong activation code
    flash[:notice] =t('admin.users.activate.not_found')
    redirect_to login_path
  rescue User::AlreadyActivated
    flash[:notice] =t('admin.users.activate.already_activated')
    redirect_to login_path
  end

end
