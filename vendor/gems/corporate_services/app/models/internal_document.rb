require 'active_support/number_helper'

class InternalDocument < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ActiveSupport::NumberHelper

  belongs_to :document_group

  attachment :file

  scope :archive_files_for, ->(doc){ where('"document_group_id" = ? and "id" != ?', doc.document_group_id, doc.id) }
  scope :primary, ->{ where(:primary => true) }
  scope :archive, ->{ where(:primary => false) }

  before_save do |doc|
    if doc.title.blank?
      doc.title = doc.original_filename.split('.')[0]
    end

    if doc.document_group_id.blank?
      doc.document_group_id = DocumentGroup.create.id
    end
  end

  # called from the initializer: config/intializers/internal_document.rb
  def self.upload_document_attributes=(attrs)
    attrs.each do |k,v|
      cattr_accessor k
      send("#{k}=",v)
    end
  end

  def revision
    revs = [revision_major, revision_minor]
    revs.join('.') unless revs.all?(&:blank?)
  end

  def revision=(val)
    self.revision_major, self.revision_minor = val.split('.').map(&:to_i)
  end

  def url
    corporate_services_internal_document_path(I18n.locale, id)
  end

  def deleteUrl
    corporate_services_internal_document_path(I18n.locale, id)
  end

  def archive_files
    # in real life archive_files will never be primary, but it can happen in testing
    primary? ? self.class.archive_files_for(self).archive.all : []
  end

  def archive_files_presentation_attributes
    archive_files.map(&:presentation_attributes)
  end

  def presentation_attributes
    methods = [:url, :deleteUrl, :revision, :formatted_modification_date, :formatted_creation_date, :formatted_filesize, :archive_files_presentation_attributes].inject({}){|h, m| h[m.to_s]= send(m); h}
    attributes.
      except!("updated_at", "created_at", "lastModifiedDate", "revision_minor", "revision_major", "filesize").
      merge(methods)
  end

  def formatted_filesize
    number_to_human_size(filesize)
  end

  def formatted_modification_date
    lastModifiedDate.to_s
  end

  def formatted_creation_date
    created_at.to_s
  end

  def has_revision?
    revision_major.is_a?(Integer)
  end

  def has_archive_files?
    archive_files.count > 0
  end

  def inheritor
    archive_files.sort_by{|f| [f.revision.to_f, f.created_at]}.last
  end

  def promoted
    update_attribute(:primary, true)
    self
  end

end
