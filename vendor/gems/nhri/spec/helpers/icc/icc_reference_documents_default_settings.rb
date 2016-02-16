require 'rspec/core/shared_context'

module IccReferenceDocumentDefaultSettings
  extend RSpec::Core::SharedContext
  before do
    SiteConfig.defaults['nhri.icc_reference_documents.filetypes'] = []
    SiteConfig.defaults['nhri.icc_reference_documents.filesize'] = 5
  end
end
