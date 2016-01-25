class AccreditationRequiredDoc < InternalDocument
  def self.i18n_scope
    [:active_record, :models, :internal_document, :accreditation_required_document, :doc_title]
  end

  DocTitles = I18n.t [:compliance_statement, :legislation, :org_chart, :report, :budget], :scope => i18n_scope
end
