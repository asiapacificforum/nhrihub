class AccreditationDocumentGroup < DocumentGroup
  has_many :accreditation_required_docs, :foreign_key => :document_group_id

  #validates :title, :uniqueness => {:message => I18n.t('activemodel.errors.models.filetype.duplicate') }
  validates :title, :uniqueness => {:message => I18n.t('activemodel.errors.models.accreditation_document_group.duplicate') }

  def id_and_title
    {:document_group_id => id, :title => title}
  end
end
