require 'rspec/core/shared_context'

module IccReferenceDocumentDefaultSettings
  extend RSpec::Core::SharedContext
  before do
    SiteConfig.defaults['nhri.icc.filetypes'] = []
    SiteConfig.defaults['nhri.icc.filesize'] = 5
  end
end
