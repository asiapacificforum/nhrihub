class NamedDocumentCallbacks
  attr_accessor :type, :group_class_name, :document_class, :group_class

  def initialize(type, group_class_name)
    @type = type
    @group_class_name = group_class_name
    @document_class = type.constantize
    @group_class = group_class_name.constantize
  end

  def after_save(doc)
    if doc.document_group_id_changed? && doc.document_group_id_was.present?
      # destroy previous document group if it was empty
      previous_document_group = DocumentGroup.find(doc.document_group_id_was)
      previous_document_group.destroy if previous_document_group.empty?
    end
  end

  def before_save(doc)
    retitle_archive_docs(doc) if doc.document_group_primary?
    doc.type = type
    doc.becomes(document_class).document_group = group_class.find_or_create_by(:title => doc.title)
  end

  private
  # all documents in the group_class have the same title
  def retitle_archive_docs(doc)
    doc.document_group.internal_documents.reject(&:document_group_primary?).each do |internal_document|
      internal_document.update_attributes(:title => doc.title) # other attributes: document_group_id and type are assigned in the before_save c/b
    end
  end
end
