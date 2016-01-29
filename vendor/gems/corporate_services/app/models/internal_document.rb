class InternalDocument < ActiveRecord::Base

  belongs_to :document_group
  delegate :created_at, :to => :document_group, :prefix => true
  belongs_to :user
  alias_method :uploaded_by, :user

  attachment :file

  default_scope ->{ order(:revision_major, :revision_minor) }

  before_save do |doc|
    if doc.title.blank?
      doc.title = doc.original_filename.split('.')[0]
    end

    if doc.document_group_id.blank?
      doc.document_group_id = DocumentGroup.create.id
    end

    if doc.revision_major.nil?
      doc.revision = document_group.next_minor_revision
    end
  end

  after_destroy do |doc|
    # if it's the last document in the group, delete the group too
    if doc.document_group.empty?
      doc.document_group.destroy
    end
  end

  def as_json(options = {})
    super(:except => [:created_at, :updated_at],
          :methods => [:revision,
                       :uploaded_by,
                       :url,
                       :formatted_modification_date,
                       :formatted_creation_date,
                       :formatted_filesize,
                       :archive_files] )
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_internal_document_path(I18n.locale, self)
  end

  def formatted_modification_date
    lastModifiedDate.to_s
  end

  def formatted_creation_date
    created_at.to_s
  end

  def formatted_filesize
    ActiveSupport::NumberHelper.number_to_human_size(filesize)
  end

  def <=>(other)
    [revision_major, revision_minor] <=> [other.revision_major, other.revision_minor]
  end

  def self.maximum_filesize
    SiteConfig['corporate_services.internal_documents.filesize']*1000000
  end

  def self.permitted_filetypes
    SiteConfig['corporate_services.internal_documents.filetypes'].to_json
  end

  # called from the initializer: config/intializers/internal_document.rb
  # hmmmm... don't see it there, maybe it's obsolete... TODO check this
  def self.upload_document_attributes=(attrs)
    attrs.each do |k,v|
      cattr_accessor k
      send("#{k}=",v)
    end
  end

  def document_group_primary
    document_group.primary
  end

  def revision
    revs = [revision_major, revision_minor]
    revs.join('.') unless revs.all?(&:blank?)
  end

  def revision=(val)
    self.revision_major, self.revision_minor = val.split('.').map(&:to_i) if val
  end

  def primary?
    document_group_primary == self
  end

  def archive_files
    if primary?
      document_group.internal_documents.reject{|doc| doc == self}
    else
      []
    end
  end

  def archive_files=(files)
    files.each do |file|
      file[:document_group_id] = document_group_id
      self.class.create(file)
    end
  end

  def has_revision?
    revision_major.is_a?(Integer)
  end

  def has_archive_files?
    archive_files.count > 0
  end

end
