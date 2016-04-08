class GoodGovernance::InternalDocumentsController < ApplicationController
  def index
    @internal_document = GoodGovernance::InternalDocument.new
    @internal_documents = GoodGovernance::DocumentGroup.non_empty.map(&:primary)
    @required_files_titles = AccreditationDocumentGroup.all.map(&:id_and_title)
    @model_name = GoodGovernance::InternalDocument.to_s
    @i18n_key = @model_name.tableize.gsub(/\//,'.')
    render 'internal_documents/index'
  end
end
