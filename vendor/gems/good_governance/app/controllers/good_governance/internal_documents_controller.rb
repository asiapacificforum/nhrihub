class GoodGovernance::InternalDocumentsController < ApplicationController
  def index
    @internal_document = GoodGovernance::InternalDocument.new
    @internal_documents = GoodGovernance::DocumentGroup.non_empty.map(&:primary)
  end
end
