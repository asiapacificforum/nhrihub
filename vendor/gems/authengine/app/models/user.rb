# EVENT                  AFTER SAVE                     NONCE                                 MAIL ON SAVE                      PASSWORD VALIDATE
# create                 signup_notify                  activation_code                       signup_notification               N
# activate               activate_notify                                                      activate_notification             Y
# forgot_password        forgotten_password_notify      password_reset_code                   forgotten_password_notification   N
# reset_password         reset_password_notify                                                reset_password_notification       N
# lost_token             lost_token_notify              replacement_token_registration_code   lost_token_notification           Y
# resend_registration    resend_registration_notify     activation_code                       resend_registration_notification  N
#
require 'digest/sha1'
class User < ActiveRecord::Base
  include Notifier
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

  def lost_token?
    @lost_token
  end

  def self.register_new_token(activation_params)
    #find by login params username/pw
    #todo better to include replacement_token_registration_code as an additional auth param
    user = find_and_authenticate_by_login_params(activation_params[:login], activation_params[:password])
    user.update_attributes(activation_params.slice(:u2f_register_response).merge(:replacement_token_registration_code => nil))
  end

  def self.find_by_password_reset_code(password_reset_code)
    raise BlankPasswordResetCode if password_reset_code.blank?
    # find_by! raises ActiveRecord::RecordNotFound if not found
    find_by!(:password_reset_code => password_reset_code)
  end

  def self.find_by_replacement_token_registration_code(replacement_token_registration_code)
    raise BlankReplacementTokenRegistrationCode if replacement_token_registration_code.blank?
    # find_by! raises ActiveRecord::RecordNotFound if not found
    find_by!(:replacement_token_registration_code => replacement_token_registration_code)
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
  validates_length_of       :password, :within => 4..40, :if => :password_required?, :on=>:update
  validates_confirmation_of :password,                   :if => :password_confirmation_required?, :on=>:update
  validates_presence_of     :password_confirmation,      :if => :password_confirmation_required?, :on=>:update
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
  has_many :reminders
  has_many :media_appearances
  has_many :assigns, :autosave => true, :dependent => :destroy
  has_many :complaints, :through => :assigns

  before_save :encrypt_password
  before_create {|user| user.make_access_nonce('activation_code') }



  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  # If the ability to add users was extended, may wish to change the attr_accessible to make sure a user cannot assign
  # themselves to a higher-privileged role
  # TODO in this application, users are trusted, but see how this should be implemented if users are not trusted
  #attr_accessible :login, :email, :password, :password_confirmation, :firstName, :lastName, :user_roles_attributes, :organization_id

  class PermissionsNotConfigured < StandardError
    attr_reader :message
    def initialize(controller,action)
      @message = "Permissions not yet configured for #{controller}/#{action}"
    end
  end
  class ActivationCodeNotFound < StandardError; end
  class BlankActivationCode < StandardError; end
  class BlankPasswordResetCode < StandardError; end
  class AlreadyActivated < StandardError
    attr_reader :user, :message;
    def initialize(user, message=nil)
      @message, @user = message, user
    end
  end
  class BlankPasswordResetCode < StandardError; end
  class AuthenticationError < StandardError
    def initialize
      super I18n.t("exceptions.#{self.class.name.underscore}")
    end
  end
  class BlankReplacementTokenRegistrationCode < AuthenticationError; end
  class TokenError < AuthenticationError; end
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
    user = find_with_activation_code(activation_code)
    user.send(:activate!)
    user
  end

  def self.find_with_activation_code(activation_code)
    raise BlankActivationCode if activation_code.nil?
    user = find_by_activation_code(activation_code)
    raise ActivationCodeNotFound if !user
    # TODO this (next) exception is raised on normal logins... it shouldn't be
    # as a workaround the flash message has been changed to eliminate the word 'already'
    # but this workaround means that the already active exception doesn't have a good error message
    raise AlreadyActivated.new(user) if user.active?
    user
  end

  def self.find_by_login(login)
    raise LoginNotFound if login.blank?
    user = find_by(:login => login)
    raise LoginNotFound if user.nil?
    raise AccountNotActivated.new unless user.active? # never see this as user would be nil, login is blank if user is not activated
    raise AccountDisabled.new unless user.enabled?
    user
  end

  def self.find_and_generate_challenge(login)
    # password is not checked until challenge response is verified
    # at this point we only see if there's a matching login
    user = User.find_by_login(login)
    user.generate_challenge
  end

  # Authenticates a user by their login name, unencrypted password, and u2f_sign_response.  Returns the user or nil.
  def self.authenticate(login, password, u2f_sign_response)
    user = User.find_by_login(login)
    return user if user.authenticated?(password, u2f_sign_response)
  end

  def self.find_and_authenticate_by_login_params(login, password)
    user = User.find_by_login(login)
    return user if user.authenticated_password?(password)
  end

  def active?
    # the presence of an activation date means they have activated
    !activated_at.nil?
  end

  def has_chosen_password?
    !crypted_password.nil? && !salt.nil?
  end

  # Returns true if the user has just been activated.
  def pending?
    @activated
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
    return true if TwoFactorAuthentication.disabled?
    u2f = U2F::U2F.new(APPLICATION_ID)
    response = JSON.parse(u2f_sign_response)
    raise TokenError if response.has_key?("errorCode")
    sign_response = U2F::SignResponse.load_from_json(u2f_sign_response)
    begin
      # authenticate! generates exceptions for any failure condition
      u2f.authenticate!(challenge, sign_response, Base64.urlsafe_decode64(public_key), 0)
      true
    rescue
      false
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

  def email_with_name
    "#{first_last_name} <#{email}>"
  end

  # called from users_controller#send_change_authentication_email
  def prepare_to_send_lost_token_email
    @lost_token = true
    nullify_public_key_params
    make_access_nonce('replacement_token_registration_code')
  end

  def nullify_public_key_params
    update_attributes(:public_key => nil, :public_key_handle => nil)
  end

  # called from users_controller#send_change_authentication_email
  def prepare_to_send_password_reset_email
    @forgotten_password = true
    make_access_nonce('password_reset_code')
  end

  def prepare_to_send_signup_email
    make_access_nonce("activation_code")
  end

  def self.forgot_password(login)
    user = User.find_by_login(login)
    user.prepare_to_send_password_reset_email
    user.save # triggers email
  end

  def reset_password
    # First update the password_reset_code before setting the
    # reset_password flag to avoid duplicate email notifications.
    update_attribute(:password_reset_code, nil)
    @reset_password = true
  end

  def recently_forgot_password?
    @forgotten_password
  end

  def recently_reset_password?
    @reset_password
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

protected

  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if salt.blank?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    (crypted_password.blank? || # validate the password field if there's no crypted password
      # this doesn't make sense... don't validate presence of password if it's blank! TODO fix this
      !password.blank?) # validate the password field if it's being provided
  end

  def password_confirmation_required?
    password_required?
  end

  def make_access_nonce(type)
    send("#{type}=", AccessNonce.create)
  end

  def destroy_access_nonce(type)
    send("#{type}=", nil)
  end


private

  def activate!
    @activated = true
    self.update_attribute(:activated_at, Time.now.utc)
    @activated = false
  end

end
