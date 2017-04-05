class ComplaintDocument < ActiveRecord::Base
  include FileConstraints

  ConfigPrefix = 'complaint_document'

  attachment :file

  def as_json(options={})
    super(:except => [:updated_at, :created_at], :methods => [:url, :serialization_key])
  end

  def url
    Rails.application.routes.url_helpers.complaint_document_path(I18n.locale, id)
  end

  def serialization_key
    'complaint[complaint_documents_attributes][]'
  end

  # TODO need to harmonize column names throughout the app
  def original_filename
    filename
  end

end
