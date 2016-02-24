require 'active_support/concern'
module FileConstraints
  extend ActiveSupport::Concern

  module ClassMethods
    def maximum_filesize
      SiteConfig[self::ConfigPrefix+'.filesize']
    end

    def maximum_filesize=(val)
      SiteConfig[self::ConfigPrefix+'.filesize'] = val
    end

    def permitted_filetypes
      SiteConfig[self::ConfigPrefix+'.filetypes']
    end

    def permitted_filetypes=(val)
      SiteConfig[self::ConfigPrefix+'.filetypes'] = val
    end
  end
end
