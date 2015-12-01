class OutreachMedia::OutreachEventsController < ApplicationController
  def index
    @outreach_events = OutreachEvent.all
    @outreach_event = OutreachEvent.new
    @areas = Area.all
    @subareas = Subarea.extended
  end

end
