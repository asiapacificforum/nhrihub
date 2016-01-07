class OutreachMedia::OutreachEvents::OutreachEventDocumentsController < ApplicationController
  def destroy
    if OutreachEventDocument.find(params[:id]).destroy
      render :nothing => true, :status => 200
    end
  end
end
