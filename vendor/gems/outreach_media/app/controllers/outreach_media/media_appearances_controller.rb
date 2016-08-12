class OutreachMedia::MediaAppearancesController < ApplicationController
  def index
    @media_appearances = MediaAppearance.includes(:subareas, :violation_severity, :positivity_rating, :performance_indicators, :notes, :reminders, :areas => :subareas).all
    @media_appearance = MediaAppearance.new
    @areas = Area.includes(:subareas).all
    @subareas = Subarea.extended
    @planned_results = PlannedResult.all_with_associations
  end

  def create
    ma = MediaAppearance.new(media_appearance_params)
    if ma.save
      render :json => ma, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    media_appearance = MediaAppearance.find(params[:id])
    media_appearance.destroy
    head :ok
  end

  def update
    media_appearance = MediaAppearance.find(params[:id])
    media_appearance.update_attributes(media_appearance_params)
    render :json => media_appearance, :status => 200
  end

  def show
    media_appearance = MediaAppearance.find(params[:id])
    send_opts = { :filename => media_appearance.original_filename,
                  :type => media_appearance.original_type,
                  :disposition => :attachment }
    send_file media_appearance.file.to_io, send_opts
  end

  private
  def media_appearance_params
    if !(params[:media_appearance][:article_link].blank? || params[:media_appearance][:article_link] == "null") || params[:media_appearance][:file] == "_remove"
      params["media_appearance"]["original_filename"] = nil
      params["media_appearance"]["filesize"] = nil
      params["media_appearance"]["original_type"] = nil
      params[:media_appearance][:remove_file] = true
    end
    params["media_appearance"]["user_id"] = current_user.id
    params.
      require(:media_appearance).
      permit(:title,
             :affected_people_count,
             :positivity_rating_id,
             :violation_severity_id,
             :file,
             :remove_file,
             :original_filename,
             :filesize,
             :original_type,
             :lastModifiedDate,
             :article_link,
             :user_id,
             :performance_indicator_associations_attributes => [:association_id, :performance_indicator_id],
             :area_ids => [],
             :subarea_ids => [])
  end

end
