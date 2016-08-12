class OutreachMedia::OutreachEvents::OutreachEventDocumentsController < ApplicationController
  def destroy
    if OutreachEventDocument.find(params[:id]).destroy
      head :ok
    end
  end

  def show
    doc = OutreachEventDocument.find(params[:id])
    send_opts = { :filename => doc.file_filename,
                  :type => doc.file_content_type,
                  :disposition => :attachment }
    send_file doc.file.to_io, send_opts
  end
end
