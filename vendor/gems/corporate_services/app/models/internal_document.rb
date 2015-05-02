require 'active_support/number_helper'

class InternalDocument < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ActiveSupport::NumberHelper

  belongs_to :document_group

  attachment :file

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

  def presentation_attributes
    methods = [:url, :deleteUrl, :revision, :formatted_filesize].inject({}){|h, m| h[m.to_s]= send(m); h}
    attributes.
      except!("updated_at", "revision_minor", "revision_major", "filesize").
      merge(methods)
  end

  def formatted_filesize
    number_to_human_size(filesize)
  end

end
