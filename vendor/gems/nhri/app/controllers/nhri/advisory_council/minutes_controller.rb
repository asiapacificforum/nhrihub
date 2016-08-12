class Nhri::AdvisoryCouncil::MinutesController < ApplicationController
  def index
    @advisory_council_minutes = Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.all
    @permitted_filetypes = Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.permitted_filetypes
    @maximum_filesize = Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.maximum_filesize
  end

  def create
    doc = Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.new(doc_params)
    if doc.save
      render :json => doc, :status => 200
    else
      render :plain => doc.errors.full_messages.first, :status => 422
    end
  end

  def update
    advisory_council_minutes = Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.find(params[:id])
    if advisory_council_minutes.update(doc_params)
      render :json => advisory_council_minutes, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    doc = Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.find(params[:id])
    doc.destroy
    head :ok
  end

  def show
    advisory_council_minutes = Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.find(params[:id])
    send_opts = { :filename => advisory_council_minutes.original_filename,
                  :type => advisory_council_minutes.original_type,
                  :disposition => :attachment }
    send_file advisory_council_minutes.file.to_io, send_opts
  end

  private
  def doc_params
    params.require(:advisory_council_minutes).permit(:date, :file, :filesize, :original_type, :original_filename, :lastModifiedDate)
  end
end
