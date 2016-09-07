require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password, :u2f_register_response

# when user account is first created, only firstname, lastname and email are required
  validates_presence_of     :firstName, :lastName, :email
  validates_length_of       :email,    :within => 6..100
  validate :create_with_unique_email, :on => :create
  validate :create_with_unique_first_last_name, :on => :create
  validate :update_with_unique_email, :on => :update
  validate :update_with_unique_first_last_name, :on => :update

  scope :active, ->{ where("status != 'deleted'") }
  scope :staff, ->{ joins(:roles).where("roles.name = 'staff'") }

  #after_create :signup_notify
  after_commit :signup_notify, :on => :create # don't send email if user is not valid
  after_save :activate_notify
  after_save :forgotten_password_notify
  after_save :reset_password_notify

  def self.find_by_password_reset_code(password_reset_code)
    raise BlankResetCode if password_reset_code.blank?
    find_by!(:password_reset_code => password_reset_code)
  end

  def register_request
    u2f = U2F::U2F.new(APPLICATION_ID)
    self.challenge = u2f.challenge
    self.challenge_timestamp = DateTime.now.utc
    save(:validate => false) # since it may not be valid at this point... there's no password
    U2F::RegisterRequest.new(challenge,APPLICATION_ID).to_json
  end

  def u2f_register_response=(json)
    response = U2F::RegisterResponse.load_from_json(json)
    self.public_key = response.public_key #base64 encoded
    self.public_key_handle = response.key_handle #base64 encoded
  end

  def signup_notify
    Authengine::UserMailer.signup_notification(self).deliver_now
  end

  def activate_notify
    if pending?
      Authengine::UserMailer.activation(self).deliver_now
    end
  end

  def forgotten_password_notify
    if recently_forgot_password?
      Authengine::UserMailer.forgot_password(self).deliver_now
    end
  end

  def reset_password_notify
    if recently_reset_password?
      Authengine::UserMailer.reset_password(self).deliver_now
    end
  end

  # custom validator rather than built-in helper, in order to get custom message
  def create_with_unique_email
    if User.where("email ilike ?", email).exists?
      errors.add(:base, :duplicate_email)
    end
  end

  def update_with_unique_email
    if User.where("email ilike ? AND id != ?", email, id).exists?
      errors.add(:base, :duplicate_email)
    end
  end

  def create_with_unique_first_last_name
    if User.where("\"firstName\" ilike ? and \"lastName\" ilike ?", firstName, lastName).exists?
      errors.add(:base, :duplicate_first_last_name)
    end
  end

  def update_with_unique_first_last_name
    if User.where("\"firstName\" ilike ? AND \"lastName\" ilike ? AND id != ?", firstName, lastName, id).exists?
      errors.add(:base, :duplicate_first_last_name)
    end
  end
# the next action on the user's record is account activation
# at this time, login and password must be present and valid
  validates_presence_of     :login,                      :on => :update
  validates_presence_of     :password,                   :if => :password_required?, :on=>:update
  validates_presence_of     :password_confirmation,      :if => :password_required?, :on=>:update
  validates_length_of       :password, :within => 4..40, :if => :password_required?, :on=>:update
  validates_confirmation_of :password,                   :if => :password_required?, :on=>:update
  validates_length_of       :login,    :within => 3..40, :on => :update
  validates_uniqueness_of   :login, :case_sensitive => false, :on => :update

  has_many :user_roles, :dependent=>:delete_all
  accepts_nested_attributes_for :user_roles
  has_many :roles, :through=>:user_roles
  has_many :useractions, :dependent=>:delete_all
  has_many :actions, :through=>:useractions
  belongs_to :organization
  has_many :sessions
  has_many :internal_documents
  has_and_belongs_to_many :reminders
  has_many :media_appearances
  has_many :assigns, :autosave => true, :dependent => :destroy
  has_many :complaints, :through => :assigns

  before_save :encrypt_password
  before_create :make_activation_code


  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  # If the ability to add users was extended, may wish to change the attr_accessible to make sure a user cannot assign
  # themselves to a higher-privileged role
  # TODO in this application, users are trusted, but see how this should be implemented if users are not trusted
  #attr_accessible :login, :email, :password, :password_confirmation, :firstName, :lastName, :user_roles_attributes, :organization_id

  class TokenError < StandardError; end
  class PermissionsNotConfigured < StandardError
    attr_reader :message
    def initialize(controller,action)
      @message = "Permissions not yet configured for #{controller}/#{action}"
    end
  end
  class ActivationCodeNotFound < StandardError; end
  class ArgumentError < StandardError; end
  class AlreadyActivated < StandardError
    attr_reader :user, :message;
    def initialize(user, message=nil)
      @message, @user = message, user
    end
  end
  class ResetCodeNotFound < StandardError; end
  class BlankResetCode < StandardError; end
  class AuthenticationError < StandardError
    def initialize
      super I18n.t("exceptions.#{self.class.name.underscore}")
    end
  end
  class LoginNotFound < AuthenticationError; end
  class TokenNotRegistered < AuthenticationError; end
  class AccountNotActivated < AuthenticationError; end
  class AccountDisabled < AuthenticationError; end

  def org_name
    organization && organization.name
  end

  def org_phone
    organization && organization.phone
  end

  def first_last_name
    firstName+' '+lastName
  end
  alias_method :to_s, :first_last_name

  def as_json(options={})
    if options.empty?
      super(:except => [:created_at, :updated_at], :only =>[:id], :methods => [:first_last_name])
    else
      super(options)
    end
  end

  def initials
    first_initial + last_initial
  end

  def first_initial
    firstName[0].upcase
  end

  def last_initial
    lastName[0].upcase
  end

  def self.find_and_activate!(activation_code)
    raise ArgumentError if activation_code.nil?
      user = find_by_activation_code(activation_code)
    raise ActivationCodeNotFound if !user
    # TODO this (next) exception is raised on normal logins... it shouldn't be
    # as a workaround the flash message has been changed to eliminate the word 'already'
    # but this workaround means that the already active exception doesn't have a good error message
    raise AlreadyActivated.new(user) if user.active?
    user.send(:activate!)
    user
  end

  def self.find_with_activation_code(activation_code)
    raise ArgumentError if activation_code.nil?
      user = find_by_activation_code(activation_code)
    raise ActivationCodeNotFound if !user
    raise AlreadyActivated.new(user) if user.active?
    user
  end

  def active?
    # the presence of an activation date means they have activated
    !activated_at.nil?
  end

  # Returns true if the user has just been activated.
  def pending?
    @activated
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password, u2f_sign_response)
    user= where("login = ?", login).first
    if user.nil?
      raise LoginNotFound.new
    elsif user.activated_at.blank?
      raise AccountNotActivated.new
    elsif user.enabled == false
      raise AccountDisabled.new
    elsif user.authenticated?(password, u2f_sign_response)
      user
    end
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  # Here it is! the two-factors being authenticated
  def authenticated?(password, u2f_sign_response)
    authenticated_password?(password) && authenticated_token?(u2f_sign_response)
  end

  def authenticated_token?(u2f_sign_response)
    return true if ENV.fetch('two_factor_authentication') == 'disabled'
    u2f = U2F::U2F.new(APPLICATION_ID)
    sign_response = U2F::SignResponse.load_from_json(u2f_sign_response)
    begin
      # authenticate! generates exceptions for any failure condition
      u2f.authenticate!(challenge, sign_response, Base64.urlsafe_decode64(public_key), 0)
      true
    rescue
      false
    end
  end

  def self.find_and_generate_challenge(login)
    user = User.where("login = ?", login).first
    # password is not checked until challenge response is verified
    # at this point we only see if there's a matching login
    if user.nil?
      raise LoginNotFound.new
    else
      user.generate_challenge
    end
  end

  def generate_challenge
    if public_key.nil? or public_key_handle.nil?
      raise TokenNotRegistered.new
    else
      self.challenge = U2F::U2F.new(APPLICATION_ID).challenge
      save(:validation => false)
      # TODO if user does not have a public_key_handle -> generate error (exception?)
      [public_key_handle, challenge]
    end
  end

  def authenticated_password?(password)
    raise LoginNotFound unless crypted_password == encrypt(password)
    true
  end

  #TODO eliminate remember_token everywhere!
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  def email_with_name
    "#{first_last_name} <#{email}>"
  end

  def prepare_to_send_reset_email
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password
    # First update the password_reset_code before setting the
    # reset_password flag to avoid duplicate email notifications.
    update_attribute(:password_reset_code, nil)
    @reset_password = true
  end

  #used in user_observer
  def recently_forgot_password?
    @forgotten_password
  end

  def recently_reset_password?
    @reset_password
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(:validate => false)
  end

  def has_role?(name)
    self.roles.find_by_name(name) ? true : false
  end

  def is_developer?
    has_role?("developer")
  end

  def is_admin?
    has_role?("admin")
  end

  def self.create_by_sql(attributes)
    user = User.new(attributes)
    user.send('encrypt_password')
    user.send('make_activation_code')
    now = DateTime.now.to_formatted_s(:db)
    query = <<-SQL
    INSERT INTO users
        (activated_at, activation_code, created_at, crypted_password, email, enabled, "firstName", "lastName", login, password_reset_code, remember_token, remember_token_expires_at, salt, status, type, updated_at)
        VALUES
        ( '#{now}','#{user.activation_code}','#{now}', '#{user.crypted_password}', NULL, true, '#{user.firstName}', '#{user.lastName}', '#{user.login}', NULL, NULL, NULL, '#{user.salt}', NULL, NULL,'#{now}')
    SQL
    #can't use ActiveRecord#create here as it would trigger a notification email
    ActiveRecord::Base.connection.insert_sql(query)
  end

protected

  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if salt.blank?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || # validate the password field if there's no crypted password
      !password.blank? # validate the password field if it's being provided
  end

  def make_activation_code
    # change the algorithm so that many can be created in very short time without activation_code collisions
    self.activation_code = Digest::SHA1.hexdigest( Time.now.advance(:seconds => rand(1000000)).to_s.split(//).sort_by {rand}.join )
  end

  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

private

  def activate!
    @activated = true
    self.update_attribute(:activated_at, Time.now.utc)
    @activated = false
  end

end
