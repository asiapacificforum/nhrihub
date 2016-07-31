class Communicant < ActiveRecord::Base
  has_many :communication_communicants, :dependent => :destroy
  has_many :communications, :through => :communication_communicants

  def as_json(options = {})
    super(:except => [:updated_at, :created_at])
  end
end
