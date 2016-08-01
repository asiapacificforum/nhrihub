require 'rspec/core/shared_context'

module InternalDocumentDefaultSettings
  extend RSpec::Core::SharedContext
  before do
    SiteConfig.defaults['internal_documents.filetypes'] = []
    SiteConfig.defaults['internal_documents.filesize'] = 5
  end
end
