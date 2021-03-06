# AuthenticatedSystem is 'include'd in ActionController by the authengine engine
# see lib/authengine/engine.rb
module AuthenticatedSystem
  class XhrPermissionDenied < StandardError; end

  protected
  # Returns true or false if the user is logged in.
  # Preloads @current_user with the user model if they're logged in.
  def logged_in?
    !!current_user
  end

  # Accesses the current user from the session.  Set it to nil if login fails
  # so that future calls do not hit the database.
  def current_user
    #puts "current_user: #{@current_user}"
    @current_user ||= (login_from_session || nil)
  end

  # Store the given user id in the session.
  def current_user=(new_user)
    #puts "set current_user.id to #{new_user.id}"
    session[:user_id] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
    @current_user = new_user
  end

  # Check if the user is authorized
  #
  # Override this method in your controllers if you want to restrict access
  # to only a few actions or if you want to check if the user
  # has the correct rights.
  #
  # Example:
  #
  #  # only allow nonbobs
  #  def authorized?
  #    current_user.login != "bob"
  #  end
  def authorized?
    logged_in?
  end

  # Filter method to enforce a login requirement.
  #
  # To require logins for all actions, use this in your controllers:
  #
  #   before_filter :login_required
  #
  # To require logins for specific actions, use this in your controllers:
  #
  #   before_filter :login_required, :only => [ :edit, :update ]
  #
  # To skip this in a subclassed controller:
  #
  #   skip_before_action :login_required
  #
  def login_required
    authorized? || access_denied
  end

  def not_logged_in_required
    !logged_in? || permission_denied
  end

  def check_role(role)
    unless logged_in? && @current_user.has_role?(role)
      if logged_in?
        permission_denied
      else
        store_referer
        access_denied
      end
    end
  end

  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the user is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def access_denied
    respond_to do |format|
      format.html do
        store_location
        flash.now[:error] = "You must be logged in to access this feature."
        logger.info "in authenticated_system#access_denied: redirect to session::new"
        redirect_to :controller => 'authengine/sessions', :action => 'new'
      end
      format.xml do
        request_http_basic_authentication 'Web Password'
      end
    end
  end

  def permission_denied
    # users will be redirected properly if they tried to access a
    # resource they didn't have permission for.
    # Its designed to redirect back to the last page they were on,
    # unless that page is on another site or has
    # the same address as the resource they're trying to access.
    flash[:error] = "You don't have permission to complete that action."
    if request.xhr?
      logger.info "xhr request"
      raise XhrPermissionDenied
    else
      respond_to do |format|
        format.html do
          logger.info "format.html"
          domain_name = SITE_URL
          http_referer = request.env["HTTP_REFERER"]

          referer_domain = http_referer.match(/(http:\/\/)?([^\/]*)/)[2] unless http_referer.nil?
          store_location
          store_referer

          if http_referer.nil?
            session[:refer_to] = nil
            redirect_to root_path
          elsif referer_domain != domain_name # came from another site, go to root path
            session[:refer_to] = nil
            redirect_to root_path
          elsif http_referer.match(session[:return_to]) #requesting the same page again go to root path
            redirect_to root_path
          else # go back to previous page
            redirect_to_referer_or_default(root_path)
          end
        end
        format.js do
          logger.info "format.js"
          render :plain => "You don't have permission to complete that action.", :status => '401 Unauthorized'
        end
        format.xml do
          logger.info "format.xml"
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :plain => "You don't have permission to complete that action.", :status => '401 Unauthorized'
        end
      end
    end
  end

  # Store the URI of the current request in the session.
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.fullpath
  end

  def store_referer
    session[:refer_to] = request.env["HTTP_REFERER"]
  end

  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def redirect_to_referer_or_default(default)
    redirect_to(session[:refer_to] || default)
    session[:refer_to] = nil
  end

  # Inclusion hook to make #current_user and #logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    base.send :helper_method, :current_user, :logged_in? if base.respond_to? :helper_method
  end

  # Called from #current_user.  First attempt to login by the user id stored in the session.
  def login_from_session
    #puts "login_from_session #{session[:user_id]}"
    self.current_user = User.find(session[:user_id]) if session[:user_id]
  end

end
