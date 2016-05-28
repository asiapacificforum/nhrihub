class ComplaintCategory < ActiveRecord::Base
  validates :name, :uniqueness => true
end
