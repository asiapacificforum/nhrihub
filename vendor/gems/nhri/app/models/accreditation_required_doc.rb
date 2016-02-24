# an AccreditationRequiredDoc is a document whose title is in the DocTitles array constant
class AccreditationRequiredDoc < InternalDocument
  belongs_to :accreditation_document_group, :foreign_key => :document_group_id

  before_save AccreditationRequiredDocCallbacks.new, :on => :update # creates the AccreditationDocumentGroup or associates with existing

  after_save do |doc|
    if doc.document_group_id_changed? && doc.document_group_id_was.present?
      # destroy previous document group if it was empty unless it was an accreditation required doc group
      if (empty_group = DocumentGroup.find(doc.document_group_id_was)).accreditation_required_docs.count.zero?
        empty_group.destroy
      end
    end
  end
end

