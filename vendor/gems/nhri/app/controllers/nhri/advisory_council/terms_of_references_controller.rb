class Nhri::AdvisoryCouncil::TermsOfReferencesController < ApplicationController
  def index
    @terms_of_reference_versions = TermsOfReferenceVersion.all
    @permitted_filetypes = TermsOfReferenceVersion.permitted_filetypes
    @maximum_filesize = TermsOfReferenceVersion.maximum_filesize
  end

  def create
    doc = TermsOfReferenceVersion.new(doc_params)
    if doc.save
      render :json => doc, :status => 200
    else
      render :text => doc.errors.full_messages.first, :status => 422
    end
  end

  def update
    terms_of_reference_version = TermsOfReferenceVersion.find(params[:id])
    if terms_of_reference_version.update(doc_params)
      render :json => terms_of_reference_version, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    doc = TermsOfReferenceVersion.find(params[:id])
    doc.destroy
    render :nothing => true, :status => 200
  end

  def show
    terms_of_reference_version = TermsOfReferenceVersion.find(params[:id])
    send_opts = { :filename => terms_of_reference_version.original_filename,
                  :type => terms_of_reference_version.original_type,
                  :disposition => :attachment }
    send_file terms_of_reference_version.file.to_io, send_opts
  end

  private
  def doc_params
    attrs = [:revision, :filesize, :original_type, :original_filename, :lastModifiedDate, :file]
    params.require(:terms_of_reference_version).permit(*attrs)
  end
end
