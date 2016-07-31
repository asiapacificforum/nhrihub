class CommunicationCommunicant < ActiveRecord::Base
  belongs_to :communication
  belongs_to :communicant
end
