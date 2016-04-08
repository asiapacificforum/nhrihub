class Siu::InternalDocument < InternalDocument
  belongs_to :document_group, :class_name => "Siu::DocumentGroup", :counter_cache => :archive_doc_count

  ConfigPrefix = 'corporate_services.internal_documents'

  def self.document_group_class
    Siu::DocumentGroup
  end
end
