module CorporateServices
  class Filetype < ::Filetype
    SiteConfigKey = 'corporate_services.internal_documents.filetypes'
    def initialize(attrs={})
      @site_config_key = SiteConfigKey
      super(attrs)
    end

    def self.create(val)
      @site_config_key = SiteConfigKey
      super(val)
    end
  end
end
