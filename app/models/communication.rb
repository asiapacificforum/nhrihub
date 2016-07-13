class Communication < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :user
  has_many :communication_documents, :dependent => :destroy
  accepts_nested_attributes_for :communication_documents

  default_scope { order('date DESC') }

  def as_json(options = {})
    super(:methods => [ :user, :attached_documents])
  end

  def attached_documents
    communication_documents
  end
end
