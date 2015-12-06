class OutreachMedia::OutreachEventsController < ApplicationController
  def index
    @outreach_events = OutreachEvent.all
    @outreach_event = OutreachEvent.new
    @areas = Area.all
    @subareas = Subarea.extended
  end

  def create
    oe = OutreachEvent.new(outreach_event_params)
    if oe.save
      render :json => oe, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    outreach_event = OutreachEvent.find(params[:id])
    outreach_event.update_attributes(outreach_event_params)
    render :json => outreach_event, :status => 200
  end

  private
  def outreach_event_params
    params.
      require(:outreach_event).
      permit(:title,
             :affected_people_count,
             :area_ids => [],
             :subarea_ids => [])
  end
end
