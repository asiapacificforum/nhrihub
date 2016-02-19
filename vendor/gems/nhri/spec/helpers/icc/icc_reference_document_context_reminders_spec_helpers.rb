require 'rspec/core/shared_context'
require_relative '../icc/icc_reference_document_setup_helper'

module IccReferenceDocumentContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext
  include IccReferenceDocumentSetupHelper

  before do
    setup_database
    visit nhri_icc_reference_documents_path(:en)
    open_reminders_panel
  end

end
