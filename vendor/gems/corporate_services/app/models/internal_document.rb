require 'active_support/number_helper'

class InternalDocument < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ActiveSupport::NumberHelper

  AcceptFileTypes = [:pdf, :doc, :docx]
  MaxFileSize = 3000000

  attr_reader :url, :deleteUrl

  belongs_to :document_group

  attachment :file

  scope :archive_files_for, ->(doc){ where('"document_group_id" = ? and "id" != ?', doc.document_group_id, doc.id) }
  scope :in_group_with,     ->(doc){ where('"document_group_id" = ? and "id" != ?', doc.document_group_id, doc.id) }
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

  def associated_primary
    InternalDocument.in_group_with(self).primary.first
  end

  def revision
    revs = [revision_major, revision_minor]
    revs.join('.') unless revs.all?(&:blank?)
  end

  def revision=(val)
    self.revision_major, self.revision_minor = val.split('.').map(&:to_i) if val
  end

  def archive_files
    # in real life archive_files will never be primary, but it can happen in testing
    primary? ? self.class.archive_files_for(self).archive.all : []
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

  def inheritor
    archive_files.sort_by{|f| [f.revision.to_f, f.created_at]}.last
  end

  def promoted
    update_attribute(:primary, true)
    self
  end

  def archive?
    !primary?
  end

end
