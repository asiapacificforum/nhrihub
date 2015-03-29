# This controller handles the login/logout function of the site.
require "date"

class Authengine::SessionsController < ApplicationController

  skip_before_filter :check_permissions, :only => [:new, :create, :destroy]

  def new
    @title = BANNER_LINE1 + ", " + BANNER_LINE2
  end

  # user logs in
  def create
    logger.info "user logging in with #{params[:login]}"
    authenticate_with_password(params[:login], params[:password])
  end

  # user logs out
  def destroy
    record_logout
    self.current_user.forget_me if logged_in?
    remove_session_user_roles
    cookies.delete :auth_token
    reset_session
    flash[:notice] = t '.logout'
    redirect_to login_path
  end

  def index
    if params[:start_date]
      start_date = params[:start_date]
      end_date = params[:end_date]
      user = params[:user] == "all" ? "%" : params[:user]
      @sessions = Session.
                    select("sessions.*, concat(users.firstName, ' ', users.lastName) as user_name").
                    joins(:user).
                    belonging_to_user(user).
                    logged_in_after(Time.parse(start_date).getutc).
                    logged_in_before(Time.parse(end_date).getutc)
    end

    @scope = current_user.has_role?('admin') ? "" : current_user.org_name
    users = current_user.has_role?('admin') ? User.unscoped : User.where(:organization_id => current_user.organization_id)
    @users = users.all.sort_by(&:lastName).collect{|u| [u.first_last_name, u.id]}.unshift(["All users", "all"]) 
    @user_ids = users.inject({}){|hash, u| hash[u.id] = u.first_last_name; hash}

    respond_to do |format|
      format.html
      format.json { render :json => @sessions.to_json(:only => [], :methods => [:user_name, :formatted_login_date, :formatted_logout_date]) }
    end
  end

protected

  def remove_session_user_roles
    session[:role] = SessionRole.new
  end

  def authenticate_with_password(login, password)
    user = User.authenticate(login, password)
    if user == nil
      failed_login(t '.bad_credentials')
    elsif user.activated_at.blank?
      failed_login(t '.account_not_activated')
    elsif user.enabled == false
      failed_login(t '.account_disabled')
    else
      self.current_user = user
      session[:role] = SessionRole.new
      session[:role].add_roles(user.role_ids)
      successful_login
    end
  end

private

  def failed_login(message)
    logger.info "login failed with message: #{message}"
    flash[:error] = message
    render :action => 'new'
  end

  def successful_login
    # 'remember me' is not used in this application
    #if params[:remember_me] == "1"
      #self.current_user.remember_me
      #cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    #end
#   user is already logged-in
    flash[:notice] = t '.success'
    #parameters = ActionController::Parameters.new({:session_id => session[:session_id], :user_id => session[:user_id], :login_date => Time.now})
    #Session.create_or_update(parameters.permit(:session_id, :user_id, :login_date))
    Session.create_or_update(:session_id => session[:session_id], :user_id => session[:user_id], :login_date => Time.now)
    return_to = session[:return_to]
    if return_to.nil?
      redirect_to home_path
    else
      redirect_to return_to
    end
  end

  def record_logout
    if s = Session.where(:session_id => session[:session_id]).first
      s.update_attribute(:logout_date, Time.now)
    end
  end

end
