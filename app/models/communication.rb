class Communication < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :user
  has_many :communication_documents, :dependent => :destroy

  def as_json(options = {})
    super(:methods => [ :user, :communication_documents])
  end
end
