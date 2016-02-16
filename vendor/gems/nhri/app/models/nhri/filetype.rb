module Nhri
  class Filetype < ::Filetype
    SiteConfigKey = 'nhri.icc.filetypes'
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
