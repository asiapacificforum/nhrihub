class OutreachMedia::OutreachEventsController < ApplicationController
  def index
    @outreach_events = OutreachEvent.all.sort_by(&:event_date).reverse
    @outreach_event = OutreachEvent.new(:event_date => DateTime.now)
    @areas = Area.all
    @subareas = Subarea.extended
    @audience_types = AudienceType.all
    @impact_ratings = ImpactRating.all
    @planned_results = PlannedResult.all_with_associations
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
    oep = outreach_event_params.dup
    if oep[:outreach_event_documents]
      docs = oep.delete(:outreach_event_documents).collect do |doc|
        OutreachEventDocument.new(doc)
      end
    else
      docs = []
    end
    outreach_event = OutreachEvent.find(params[:id])
    outreach_event.outreach_event_documents += docs
    outreach_event.update_attributes(oep)
    render :json => outreach_event, :status => 200
  end

  def destroy
    outreach_event = OutreachEvent.find(params[:id])
    outreach_event.destroy
    render :nothing => true, :status => 200
  end

  private

  def outreach_event_params
    params.
      require(:outreach_event).
      permit(:title,
             :affected_people_count,
             :audience_name,
             :description,
             :date,
             :participant_count,
             :audience_type_id,
             :impact_rating_id,
             :outreach_event_documents_attributes =>['outreach_event_id', 'file', 'file_filename', 'file_size', 'file_content_type'],
             :performance_indicator_ids => [],
             :area_ids => [],
             :subarea_ids => [])
  end
end
