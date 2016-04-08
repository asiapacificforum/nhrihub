class Nhri::ProtectionPromotion::InternalDocumentsController < ApplicationController
  def index
    @internal_document = Nhri::ProtectionPromotion::InternalDocument.new
    @internal_documents = Nhri::ProtectionPromotion::DocumentGroup.non_empty.map(&:primary)
    @required_files_titles = AccreditationDocumentGroup.all.map(&:id_and_title)
    @model_name = Nhri::ProtectionPromotion::InternalDocument.to_s
    @i18n_key = @model_name.tableize.gsub(/\//,'.')
    render 'internal_documents/index'
  end
end
