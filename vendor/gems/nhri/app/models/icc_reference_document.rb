class IccReferenceDocument < ActiveRecord::Base
  ConfigPrefix = 'nhri.icc_reference_documents'

  belongs_to :user
  alias_method :uploaded_by, :user
  has_many :reminders, :as => :remindable, :dependent => :delete_all

  attachment :file

  before_save do |doc|
    if doc.title.blank?
      doc.title = doc.original_filename.split('.')[0]
    end
  end

  def self.maximum_filesize
    SiteConfig[ConfigPrefix+'.filesize']*1000000
  end

  def self.maximum_filesize=(val)
    SiteConfig[ConfigPrefix+'.filesize'] = val
  end

  def self.permitted_filetypes
    SiteConfig[ConfigPrefix+'.filetypes'].to_json
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

  def formatted_creation_date
    created_at.to_s
  end

  def formatted_filesize
    ActiveSupport::NumberHelper.number_to_human_size(filesize)
  end

  def namespace
    :nhri
  end
end
