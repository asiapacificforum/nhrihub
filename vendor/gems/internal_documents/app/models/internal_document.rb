class InternalDocument < ActiveRecord::Base
  include DocumentVersioning
  include FileConstraints
  include DocumentApi

  ConfigPrefix = 'internal_documents'

  belongs_to :document_group, :counter_cache => :archive_doc_count
  delegate :created_at, :to => :document_group, :prefix => true
  belongs_to :user
  alias_method :uploaded_by, :user

  attachment :file

  default_scope ->{ order(:revision_major, :revision_minor) }

  before_save do |doc|
    doc.assign_title
    doc.convert_to_accreditation_required_type
    doc.assign_to_group
    doc.assign_revision
  end

  def self.document_group_class
    DocumentGroup
  end

  def assign_to_group
    if (self.document_group_id.blank? || self.document_group_id.zero?) && !self.is_a?(AccreditationRequiredDoc)
      self.document_group_id = self.class.document_group_class.create.id
    end
  end

  def convert_to_accreditation_required_type
    # it's an InternalDocument that has been edited to an AccreditationRequiredDoc
    # or an AccreditationRequiredDoc being created
    if AccreditationDocumentGroup.pluck(:title).include?(self.title)
      NamedDocumentCallbacks.new("AccreditationRequiredDoc", "AccreditationDocumentGroup").before_save(self)
    end
  end

  def assign_title
    if self.title.blank?
      self.title = self.original_filename.split('.')[0]
    end
  end

  def assign_revision
    if self.revision_major.nil? || self.revision.to_f.zero?
      self.revision = self.document_group.next_minor_revision
    end
  end

  after_destroy do |doc|
    # if it's the last document in the group, delete the group too
    if doc.document_group && doc.document_group.reload.empty?
      doc.document_group.destroy unless doc.document_group.is_a?(AccreditationDocumentGroup)
    end
  end

  after_save do |doc|
    if doc.document_group_id_changed? && doc.document_group_id_was.present?
      if (empty_group = DocumentGroup.find(doc.document_group_id_was)).internal_documents.count.zero?
        empty_group.destroy
      end
    end
  end

  def as_json(options = {})
    super(:except => [:created_at, :updated_at],
          :methods => [:revision,
                       :uploaded_by,
                       :formatted_modification_date,
                       :formatted_creation_date,
                       :formatted_filesize,
                       :type,
                       :archive_files] )
  end

  def document_group_primary
    document_group && document_group.primary
  end

  def document_group_primary?
    document_group_primary == self
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

  def has_archive_files?
    archive_files.count > 0
  end

end
