class Nhri::AdminController < ApplicationController
  def index
    @doc_groups = AccreditationDocumentGroup.all.map(&:title)
    @doc_group = AccreditationDocumentGroup.new
  end
end
