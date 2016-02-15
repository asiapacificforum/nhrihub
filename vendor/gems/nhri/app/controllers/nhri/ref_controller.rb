class Nhri::RefController < ApplicationController
  def index
    @icc_reference_document = IccReferenceDocument.new
    @icc_reference_documents = IccReferenceDocument.all
  end
end
