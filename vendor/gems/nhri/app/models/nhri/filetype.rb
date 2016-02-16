module Nhri
  class Filetype < ::Filetype
    def initialize(attrs={})
      @site_config_key = IccReferenceDocument::ConfigPrefix+'.filetypes'
      super(attrs)
    end

    def self.create(val)
      @site_config_key = IccReferenceDocument::ConfigPrefix+'.filetypes'
      super(val)
    end
  end
end
