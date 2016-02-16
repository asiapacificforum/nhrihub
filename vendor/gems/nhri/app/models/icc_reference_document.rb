class IccReferenceDocument < ActiveRecord::Base
  def self.maximum_filesize
    SiteConfig['nhri.icc_reference_documents.filesize']*1000000
  end

  def self.permitted_filetypes
    SiteConfig['nhri.icc_reference_documents.filetypes'].to_json
  end
end
