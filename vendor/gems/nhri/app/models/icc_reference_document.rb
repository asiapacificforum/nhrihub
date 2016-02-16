class IccReferenceDocument < ActiveRecord::Base
  ConfigPrefix = 'nhri.icc_reference_documents'
  def self.maximum_filesize
    SiteConfig[ConfigPrefix+'.filesize']*1000000
  end

  def self.permitted_filetypes
    SiteConfig[ConfigPrefix+'.filetypes'].to_json
  end
end
