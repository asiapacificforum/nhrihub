class Communication < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :user
  has_many :communication_documents, :dependent => :destroy
  accepts_nested_attributes_for :communication_documents
  has_many :communication_communicants, :dependent => :destroy
  has_many :communicants, :through => :communication_communicants
  accepts_nested_attributes_for :communicants

  default_scope { order('date DESC') }

  #def date=(value)
    #if value.is_a? String # it's a user-entered value
      #date = DateTime.parse(value).to_date.to_s # strip the timezone that is attached
      #value = Time.zone.parse(date) # the user-entered value interpreted in the app's timezone
    #end
      #write_attribute(:date, value)
  #end

  #def date
    #raw_date = read_attribute(:date) # it's already converted to the app's timezone
    #raw_date.to_date # extract the date part
  #end

  def as_json(options = {})
    super(:methods => [ :user, :attached_documents, :communicants])
  end

  def attached_documents
    communication_documents
  end
end
