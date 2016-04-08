class GoodGovernance::InternalDocument < InternalDocument
  belongs_to :document_group, :class_name => "GoodGovernance::DocumentGroup", :counter_cache => :archive_doc_count

  ConfigPrefix = 'corporate_services.internal_documents'

  def self.document_group_class
    GoodGovernance::DocumentGroup
  end
end
