require 'rspec/core/shared_context'

module IccReferenceDocumentSetupHelper
  extend RSpec::Core::SharedContext
  def setup_database
    FactoryGirl.create(:icc_reference_document, :with_reminder)
  end
end
