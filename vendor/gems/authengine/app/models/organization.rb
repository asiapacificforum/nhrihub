class Organization < ActiveRecord::Base
  #include ActionView::Helpers::NumberHelper

  validates :name, presence: true
  validates :name, uniqueness: {message: "already exists, organization name must be unique."}

  has_many :users
  serialize :contacts, ContactList

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

  def <=>(other)
    name.downcase <=> other.name.downcase
  end
end
