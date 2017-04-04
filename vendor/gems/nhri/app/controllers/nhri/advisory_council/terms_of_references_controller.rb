class Nhri::AdvisoryCouncil::TermsOfReferencesController < ApplicationController
  include AttachedFile

  def index
    @terms_of_reference_versions = Nhri::AdvisoryCouncil::TermsOfReferenceVersion.all
    @permitted_filetypes = Nhri::AdvisoryCouncil::TermsOfReferenceVersion.permitted_filetypes
    @maximum_filesize = Nhri::AdvisoryCouncil::TermsOfReferenceVersion.maximum_filesize
  end

  def create
    doc = Nhri::AdvisoryCouncil::TermsOfReferenceVersion.new(doc_params)
    if doc.save
      render :json => doc, :status => 200
    else
      render :plain => doc.errors.full_messages.first, :status => 422
    end
  end

  def update
    terms_of_reference_version = Nhri::AdvisoryCouncil::TermsOfReferenceVersion.find(params[:id])
    if terms_of_reference_version.update(doc_params)
      render :json => terms_of_reference_version, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    doc = Nhri::AdvisoryCouncil::TermsOfReferenceVersion.find(params[:id])
    doc.destroy
    head :ok
  end

  def show
    send_attached_file( Nhri::AdvisoryCouncil::TermsOfReferenceVersion.find(params[:id]) )
  end

  private
  def doc_params
    attrs = [:revision, :filesize, :original_type, :original_filename, :lastModifiedDate, :file]
    params.require(:terms_of_reference_version).permit(*attrs)
  end
end
