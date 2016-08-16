class IccReferenceDocument < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include FileConstraints
  include DocumentApi
  ConfigPrefix = 'nhri.icc_reference_documents'

  belongs_to :user
  alias_method :uploaded_by, :user
  has_many :reminders, :as => :remindable, :dependent => :destroy

  attachment :file

  before_save do |doc|
    if doc.title.blank?
      doc.title = doc.original_filename.split('.')[0]
    end
  end

  def as_json(options = {})
    super(:except  => [:created_at, :updated_at],
          :methods => [:uploaded_by,
                       :url,
                       :formatted_creation_date,
                       :formatted_filesize,
                       :reminders,
                       :create_reminder_url ] )
  end

  def url
    if persisted?
      Rails.application.routes.url_helpers.nhri_icc_reference_document_path(I18n.locale, self)
    end
  end

  def create_reminder_url
    Rails.application.routes.url_helpers.nhri_icc_reference_document_reminders_path(:en,id) if persisted?
  end

  def remindable_url(remindable_id)
    nhri_icc_reference_document_reminder_path('en',id,remindable_id)
  end

end
