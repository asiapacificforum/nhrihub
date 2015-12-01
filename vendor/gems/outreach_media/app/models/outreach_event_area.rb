class OutreachEventArea < ActiveRecord::Base
  belongs_to :outreach_event
  belongs_to :area

  def as_json(options={})
    super({:except => [:updated_at, :created_at, :outreach_event_id, :id],
           :methods => [:subarea_ids]})
  end

  def subarea_ids
    outreach_events.subareas.where(:area_id => area_id).pluck('id')
  end

end
