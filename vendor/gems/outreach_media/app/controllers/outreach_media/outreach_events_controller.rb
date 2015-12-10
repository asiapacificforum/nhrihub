class OutreachMedia::OutreachEventsController < ApplicationController
  def index
    @outreach_events = OutreachEvent.all
    @outreach_event = OutreachEvent.new
    @areas = Area.all
    @subareas = Subarea.extended
    @audience_types = AudienceType.all
    @impact_ratings = ImpactRating.all
  end

  def create
    oep = outreach_event_params.dup
    if oep[:outreach_event_documents]
      docs = oep.delete(:outreach_event_documents).collect do |doc|
        OutreachEventDocument.new(doc)
      end
    else
      docs = []
    end
    oe = OutreachEvent.new(oep)
    oe.outreach_event_documents = docs
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
             :audience_name,
             :description,
             :participant_count,
             :audience_type_id,
             :outreach_event_documents =>[:file],
             :area_ids => [],
             :subarea_ids => [])
  end
end
