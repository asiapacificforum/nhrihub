require 'rspec/core/shared_context'

module InternalDocumentDefaultSettings
  extend RSpec::Core::SharedContext
  before do
    SiteConfig.defaults['corporate_services.internal_documents.filetypes'] = []
    SiteConfig.defaults['corporate_services.internal_documents.filesize'] = 5
  end
end
