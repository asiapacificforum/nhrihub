require 'active_support/concern'
module FileConstraints
  extend ActiveSupport::Concern

  module ClassMethods
    def filesize_config_param
      self::ConfigPrefix+'.filesize'
    end

    def filetypes_config_param
      self::ConfigPrefix+'.filetypes'
    end

    def maximum_filesize
      SiteConfig[filesize_config_param] || 5
    end

    def maximum_filesize=(val)
      SiteConfig[filesize_config_param] = val
    end

    def permitted_filetypes
      SiteConfig[filetypes_config_param] || []
    end

    def permitted_filetypes=(val)
      SiteConfig[filetypes_config_param] = val
    end
  end
end
