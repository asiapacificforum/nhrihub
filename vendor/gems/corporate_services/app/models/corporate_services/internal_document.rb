class CorporateServices::InternalDocument < InternalDocument

  ConfigPrefix = 'corporate_services.internal_documents'

  belongs_to :document_group, :class_name => "CorporateServices::DocumentGroup", :counter_cache => :archive_doc_count

  def self.document_group_class
    CorporateServices::DocumentGroup
  end
end
