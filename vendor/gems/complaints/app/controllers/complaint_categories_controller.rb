class ComplaintCategoriesController < ApplicationController
  def create
    category = ComplaintCategory.new(category_params)
    if category.save
      render :text => category.name, :status => 200, :content_type => 'text/plain'
    else
      render :text => category.errors.full_messages.first, :status => 422
    end
  end

  def destroy
    category = ComplaintCategory.find_by(:name => params[:id])
    category.destroy
    render :nothing => true, :status => 200
  end

private
  def category_params
    params.require(:complaint_category).permit(:name)
  end

end
