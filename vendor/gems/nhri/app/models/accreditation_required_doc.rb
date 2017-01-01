# an AccreditationRequiredDoc is a document whose title is one of the special titles configured via admin
# it is a special type of internal document, accessible through the NHRI -> GANHRI accreditation -> Internal Documents menu
class AccreditationRequiredDoc < InternalDocument
  belongs_to :accreditation_document_group, :foreign_key => :document_group_id

  def self.callback_class
    @callback_class ||= NamedDocumentCallbacks.new("AccreditationRequiredDoc", "AccreditationDocumentGroup")
  end

  before_save callback_class, :on => :update # creates the AccreditationDocumentGroup or associates with existing
  after_save callback_class

  alias_method :document_group, :accreditation_document_group
end

