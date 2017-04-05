class CommunicationDocument < ActiveRecord::Base
  include FileConstraints

  ConfigPrefix = 'communication_document'

  belongs_to :communication

  attachment :file

  def as_json(options={})
    super(:except => [:updated_at, :created_at])
  end

  # TODO need to harmonize column names throughout the app
  def original_filename
    filename
  end

end

