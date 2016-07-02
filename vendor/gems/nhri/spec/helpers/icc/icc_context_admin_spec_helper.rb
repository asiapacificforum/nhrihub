require 'rspec/core/shared_context'

module IccContextAdminSpecHelper
  extend RSpec::Core::SharedContext
  include IccAdminSpecHelper

  def model
    IccReferenceDocument
  end

  def filesize_selector
    '#icc_reference_document'
  end

  def filesize_context
    page.find('#icc_reference_document')
  end

  def filetypes_context
    page.find('#icc_reference_document_filetypes')
  end

  def filetypes_selector
    '#icc_reference_document_filetypes'
  end

  def admin_page
    nhri_admin_path('en')
  end
end
