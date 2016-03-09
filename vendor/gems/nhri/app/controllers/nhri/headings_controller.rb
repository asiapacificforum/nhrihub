class Nhri::HeadingsController < ApplicationController
  def index
    @headings = Nhri::Indicator::Heading.all
  end

  def create
    @heading = Nhri::Indicator::Heading.create(heading_params)
    render :json => @heading, :status => 200
  end

  def destroy
    heading = Nhri::Indicator::Heading.find(params[:id])
    heading.destroy
    render :nothing => true, :status => 200
  end

  def update
    heading = Nhri::Indicator::Heading.find(params[:id])
    if heading.update(heading_params)
      render :json => heading, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def show
    @heading = Nhri::Indicator::Heading.includes(:offences, :indicators).find(params[:id])
  end

  private
  def heading_params
    params.require(:heading).permit(:title)
  end
end
