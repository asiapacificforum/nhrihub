class ComplaintBasesController < ApplicationController
  def create
    complaint_basis = @model.new(complaint_basis_params)
    if complaint_basis.save
      render :plain => complaint_basis.name, :status => 200, :content_type => 'text/plain'
    else
      render :plain => complaint_basis.errors.full_messages.first, :status => 422
    end
  end

  def destroy
    complaint_basis = @model.find_by(:name => params[:id])
    complaint_basis.destroy
    head :ok
  end

end
