# This controller handles the login/logout function of the site.
require "date"

class Authengine::SessionsController < ApplicationController

  skip_before_action :check_permissions, :only => [:new, :create, :destroy]

  def new
    @title = t('banner.line_1') + ", " + t('banner.line_2')
    render login_template
  end

  # user logs in
  def create
    respond_to do |format|
      # user on the login page requests by ajax a challenge that they will
      # sign to prove posession of the private key, corresponding with the
      # public key associated with the account. User is selected
      # using the username and password supplied
      #format.json do
        #key_handle, challenge = generate_challenge(params[:login])
        #if @failed_challenge_message.present?
          #render :plain => @failed_challenge_message, :status => 406
        #else
          #render :json => U2F::SignRequest.new(key_handle, challenge, APPLICATION_ID), :status => 200
        #end
      #end

      # user submits login, password and signed challenge
      format.html do
        logger.info "user logging in with #{params[:login]}"
        authenticate_and_login(params[:login], params[:password], params[:u2f_sign_response])
      end
    end
  end

  # user logs out
  def destroy
    record_logout
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
    session[:role] = Marshal.dump SessionRole.new
  end

  ## TODO should be a class method on User model
  #def generate_challenge(login)
    #User.find_and_generate_challenge(login)
  #rescue User::AuthenticationError => message
    #failed_challenge message
  #end

  def authenticate_and_login(login, password, u2f_sign_response)
    user = User.authenticate(login, password, u2f_sign_response)
    successful_login user
  rescue User::AuthenticationError => message
    failed_login message
  end

private
  def login_template
    # depends on two_factor_authentication configuration
    # it's for convenience, when we're running a demo and
    # tokens are not possible, for example
    if two_factor_authentication_required?
      'login_with_two_factor_authentication'
    else
      'login_without_two_factor_authentication'
    end
  end

  def two_factor_authentication_required?
    ENV.fetch("two_factor_authentication").blank? ||
      ENV.fetch("two_factor_authentication") == 'enabled'
  end

  def failed_challenge(message)
    @failed_challenge_message = message
  end

  def failed_login(message)
    logger.info "login failed with message: #{message}"
    flash[:error] = message
    render login_template
  end

  def successful_login(user)
    self.current_user = user
    session_role = SessionRole.new
    session_role.add_roles(user.role_ids)
    session[:role] = Marshal.dump(session_role)
    Session.create_or_update(:session_id => session[:session_id], :user_id => session[:user_id], :login_date => Time.now)
    flash[:notice] = t('.success')
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
