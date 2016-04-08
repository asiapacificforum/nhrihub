class Nhri::ProtectionPromotion::InternalDocument < InternalDocument
  belongs_to :document_group, :class_name => "Nhri::ProtectionPromotion::DocumentGroup", :counter_cache => :archive_doc_count

  ConfigPrefix = 'corporate_services.internal_documents'

  def self.document_group_class
    Nhri::ProtectionPromotion::DocumentGroup
  end
end
