# an AccreditationRequiredDoc is a document whose title is in the DocTitles array constant
class AccreditationRequiredDoc < InternalDocument
  belongs_to :accreditation_document_group, :foreign_key => :document_group_id

  def self.i18n_scope
    [:active_record, :models, :internal_document, :accreditation_required_document, :doc_title]
  end

  DocTitles = I18n.t [:compliance_statement, :legislation, :org_chart, :report, :budget], :scope => i18n_scope

  before_save AccreditationRequiredDocCallbacks.new, :on => :update # creates the AccreditationDocumentGroup or associates with existing
  after_save do |doc|
    if doc.document_group_id_changed? && doc.document_group_id_was.present?
      if (empty_group = DocumentGroup.find(doc.document_group_id_was)).accreditation_required_docs.count.zero?
        empty_group.destroy
      end
    end
  end
end

