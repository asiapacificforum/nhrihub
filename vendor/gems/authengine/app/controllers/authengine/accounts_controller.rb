class Authengine::AccountsController < ApplicationController

  # because a user cannot login until the account is activated
  skip_before_action :check_permissions, :only => [:show]

  # Activate action
  def show
    # Uncomment and change paths to have user logged in after activation - not recommended
    # self.current_user = User.find_and_activate!(params[:id])
    @user = User.find_with_activation_code(params[:activation_code])
    session[:activation_code] = params[:activation_code]
    redirect_to signup_admin_user_path(@user) # admin/users#signup
  rescue User::ArgumentError # activation_code.nil?
    flash[:notice] =t('admin.users.activate.argument_error')
    redirect_to login_path
  rescue User::ActivationCodeNotFound # wrong activation code
    flash[:notice] =t('admin.users.activate.not_found')
    redirect_to login_path
  rescue User::AlreadyActivated
    flash[:notice] =t('admin.users.activate.already_activated')
    redirect_to login_path
  end

  def edit
  end

  # Change password action
  def update
# removed to make restful (should actually be put)
#    return unless request.post?
    if User.authenticate(current_user.login, params[:old_password])
      if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
        current_user.password_confirmation = params[:password_confirmation]
        current_user.password = params[:password]
        if current_user.save
          flash[:notice] = "Password updated."
          # redirect_to user_path(current_user)
          redirect_to :controller=>session[:referer][:controller], :action=>session[:referer][:action]
        else
          flash[:error] = "An error occured, your password was not changed."
          render :action => 'edit'
        end
      else
        flash[:error] = "New password does not match the password confirmation."
        @old_password = params[:old_password]
        render :action => 'edit'
      end
    else
      flash[:error] = "Your old password is incorrect."
      render :action => 'edit'
    end
  end

end
