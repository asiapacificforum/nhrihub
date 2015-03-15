require 'contact'

class Organization < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  serialize :contacts, ContactList

  has_many :users
  has_many :households
  has_many :monthly_report_report_months
  validates :name, presence: true
  validates :name, uniqueness: {message: "already exists, referrer name must be unique."}
  scope :active, ->{ where('active = ?', true) }
  scope :inactive, ->{ where('active = ?', false) }
  scope :pantries, ->{ where('pantry = ?', true) }
  scope :referrers, ->{ where('referrer = ?', true) }
  scope :verified, ->{ where('verified = ?', true) }

  validate :either_pantry_or_referrer_must_be_true

  before_save do
    # when receiving params from organization form, contacts is an array of contact hashes
    initialize_contacts
  end

  # if save fails, the before_save callback is also rolled back,
  # we still need contacts to be a ContactList object,
  # we're redirected to the new or edit form, which needs ContactList object
  after_rollback do
    initialize_contacts
  end

  def initialize_contacts
    self.contacts = ContactList.new(self.contacts.map{|c| Contact.new(c)}) unless self.contacts.is_a?(ContactList)
  end

  def either_pantry_or_referrer_must_be_true
    errors[:base] << "Either pantry or referral agency, or both, must be checked" unless pantry || referrer
  end

  def <=>(other)
    name.downcase <=> other.name.downcase
  end

  # ONLY add this after the new contacts field has been populated
  def phone
    contacts.map{|contact|
      ActionController::Base.helpers.number_to_phone(contact.phone, :area_code => true)
    }.join("<br/>").html_safe
  end

  def errors_for_household
    all_errors = []
    errors.messages.inject(all_errors) do |all_errors, (key, messages)|
      message = key==:base ? messages : "Referrer #{key.to_s} " + messages.join(", ")
      all_errors << message
      all_errors
    end
    all_errors.join(", ")
  end
end
