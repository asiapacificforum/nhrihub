# Besides the ususal REST actions, this controller contains show_self,
# edit_self and update_self actions.
# This permits access to be explicitly controlled via the
# check_permissions filter, distinguishing between actions on one's own
# model vs. actions on other users' models.
class Authengine::UsersController < ApplicationController
  #before_filter :not_logged_in_required, :only => [:new, :create]
  #before_filter :login_required, :only => [:show, :edit, :update]
  #before_filter :check_administrator_role, :only => [:index, :destroy, :enable]
  #before_filter :user_or_current_user, :only => [:show, :edit, :update]

  # activate is where a user with the correct activation code
  # is redirected to, so they can enter passwords and login name
  skip_before_filter :check_permissions, :only=>[:activate, :signup, :new_password, :change_password]

  def index
    @users = User.
      joins("left join sessions on users.id = sessions.user_id").
      select("users.id as id, users.*, max(sessions.login_date) as last_login").
      group("users.id").
      order("lastName, firstName")
  end

  def show
    @user = User.find(params[:id])
  end

  def show_self
    @user = current_user
    render :template=>"users/show"
  end

  def new
    @user = User.new
    @user.user_roles.build
    @roles = Role.all
  end

  def user_params
    attrs = [ :email,
              :firstName,
              :lastName,
              :organization_id,
              :user_roles_attributes => [:role_id] ]
    params.require(:user).permit(attrs)
  end

# users may only be created by the administrator from the index page
  def create
    cookies.delete :auth_token
    @user = User.new(user_params)
    @user.save!
    redirect_to authengine_users_path
  rescue ActiveRecord::RecordInvalid
    flash[:error] = "There was a problem creating the user account."
    @roles=Role.all
    render :action => 'new'
  end

  def edit # edit a user profile with id given
    @user = User.find(params[:id])
  end

  def edit_self # edit profile of current user
    @user = current_user
    render :template => 'users/edit'
  end

# account was created by admin and now user is entering username/password
  def activate
    # TODO must remember to reset the session[:activation_code]
    # looks as if setting current user (next line) was causing the user to be
    # logged-in after activation
    user = User.find_and_activate!(params[:activation_code])
    if user.update_attributes(params.require(:user).slice(:login, :email, :password, :password_confirmation).permit(:login, :email, :password, :password_confirmation))
      redirect_to root_path
    else
      flash[:warn] = user.errors.full_messages
      redirect_to signup_authengine_user_path(user)
    end
  rescue User::ArgumentError
    flash[:notice] = 'Activation code not found. Please ask the database administrator to create an account for you.'
    redirect_to new_authengine_user_path
  rescue User::ActivationCodeNotFound
    flash[:notice] = 'Activation code not found. Please ask the database administrator to create an account for you.'
    redirect_to new_authengine_user_path
  rescue User::AlreadyActivated
    flash[:notice] = 'Your account has already been activated. You can log in below.'
    redirect_to login_path
  end

  def update_self
    @user = User.find(current_user.id)
    if @user.update_attributes(user_params)
      flash[:notice] = "Your profile has been updated"
      redirect_to authengine_users_path
    else
      render :action => 'edit'
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:notice] = "User updated"
      redirect_to authengine_users_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to authengine_users_path
  end

  def disable
    @user = User.find(params[:id])
    unless @user.update_attribute(:enabled, false)
      flash[:error] = "There was a problem disabling this user."
    end
    redirect_to authengine_users_path
  end

  def enable
    @user = User.find(params[:id])
    unless @user.update_attribute(:enabled, true)
      flash[:error] = "There was a problem enabling this user."
    end
    redirect_to authengine_users_path
  end

  def signup
    @user = User.find(params[:id])
  end

  # when a logged-in admin clicks "reset password"
  def send_change_password_email
    @user = User.find(params[:user_id])
    @user.prepare_to_send_reset_email
    @users = User.order("lastName, firstName").all
    if @user.save
      redirect_to authengine_users_path, :notice => "A password reset email has been sent to #{@user.first_last_name}, #{@user.email}"
    else
      redirect_to authengine_users_path, :error => "Failed to send password reset email to #{@user.first_last_name}, #{@user.email}"
    end
  end

  # where a user enters new password values, login not required
  def new_password
    password_reset_code = params[:password_reset_code]
    if password_reset_code.nil?
      redirect_to root_path, :notice => 'Invalid password reset.'
    else
      @user = User.find_by_password_reset_code(password_reset_code)
      if @user.nil?
        redirect_to root_path, :notice => "User not found"
      end
    end
  end

  # new password values have been entered and we're going to save them here
  def change_password
    password_reset_code = params[:password_reset_code]
    raise User::ArgumentError if password_reset_code.nil?

    user = User.find_by_password_reset_code(password_reset_code)
    raise User::ResetCodeNotFound if user.nil?

    if user.update_attributes(params.require(:user).permit(:password, :password_confirmation))
      redirect_to root_path, :notice => "Your new password has been saved, you may login below."
    else
      flash[:warn] = user.errors.full_messages
      redirect_to authengine_new_password_path
    end

    rescue User::ArgumentError
      redirect_to root_path, :notice => 'Invalid password reset.'
    rescue User::ResetCodeNotFound
      redirect_to root_path, :notice => 'Invalid password reset.'
  end


protected

  def user_or_current_user
    if current_user.has_role?('administrator')
      @user = User.find(params[:id])
    else
      @user = current_user
    end
  end

end
