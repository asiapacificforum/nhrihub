class ComplaintBasesController < ApplicationController
  def create
    complaint_basis = @model.new(complaint_basis_params)
    if complaint_basis.save
      render :text => complaint_basis.name, :status => 200, :content_type => 'text/plain'
    else
      render :text => complaint_basis.errors.full_messages.first, :status => 422
    end
  end

  def destroy
    complaint_basis = @model.find_by(:name => params[:id])
    complaint_basis.destroy
    render :nothing => true, :status => 200
  end

end
