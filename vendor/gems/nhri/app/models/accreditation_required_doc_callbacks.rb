class AccreditationRequiredDocCallbacks
  def before_save(doc)
    update_archive(doc) if doc.document_group_primary?
    doc.type = "AccreditationRequiredDoc"
    accreditation_document_group =
      AccreditationDocumentGroup.where(:title => doc.title).first ||
      AccreditationDocumentGroup.create(:title => doc.title)
    doc.document_group_id = accreditation_document_group.id
    doc.becomes(AccreditationRequiredDoc)
  end

  private
  def update_archive(doc)
    doc.document_group.internal_documents.reject(&:document_group_primary?).each do |internal_document|
      internal_document.update_attributes(:title => doc.title) # other attributes: document_group_id and type are assigned in the before_save c/b
    end
  end
end
