class OutreachMedia::MediaAppearancesController < ApplicationController
  def index
    @media_appearances = MediaAppearance.all
    @media_appearance = MediaAppearance.new
    @areas = Area.all
    @subareas = Subarea.extended
  end

  def create
    ma = MediaAppearance.new(media_appearance_params)
    if ma.save
      render :json => ma, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    media_appearance = MediaAppearance.find(params[:id])
    media_appearance.destroy
    render :nothing => true, :status => 200
  end

  def update
    media_appearance = MediaAppearance.find(params[:id])
    media_appearance.update_attributes(media_appearance_params)
    render :json => media_appearance, :status => 200
  end

  private
  def media_appearance_params
    params.require(:media_appearance).permit(:title, :affected_people_count, :positivity_rating_rank, :violation_severity_rank, :area_ids => [], :subarea_ids => [])
  end

end
