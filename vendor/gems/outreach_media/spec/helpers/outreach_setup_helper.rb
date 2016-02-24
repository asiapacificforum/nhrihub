require 'rspec/core/shared_context'

module OutreachSetupHelper
  extend RSpec::Core::SharedContext
  def setup_database(type = nil)
    setup_impact_ratings
    setup_areas
    FactoryGirl.create(:outreach_event,
                       :hr_area,
                       :impact_rating => ImpactRating.first,
                       :participant_count => 1000,
                       :event_date => DateTime.now,
                       :reminders=>[] )

    if type == :multiple
      FactoryGirl.create(:outreach_event,
                         :hr_area,
                         :impact_rating => ImpactRating.first,
                         :participant_count => 2000,
                         :event_date => DateTime.now,
                         :reminders=>[] )
    end
  end

  def setup_audience_types
    AudienceType::DefaultValues.each { |at| AudienceType.create(at.marshal_dump) }
  end

  def add_a_second_outreach_event
    FactoryGirl.create(:outreach_event,
                       :hr_area,
                       :impact_rating => ImpactRating.first,
                       :reminders=>[] )
  end

  def add_reminder
    ma = OutreachEvent.first
    ma.reminders << FactoryGirl.create(:reminder, :reminder_type => 'weekly', :text => "don't forget the fruit gums mum", :users => [User.first])
    ma.save
  end

  def setup_outreach_events
    FactoryGirl.create(:outreach_event)
  end

  def setup_impact_ratings
    ImpactRating::DefaultValues.each { |pr| ImpactRating.create(:rank => pr.rank) }
  end

  def setup_areas
    areas = ["Human Rights", "Good Governance", "Special Investigations Unit", "Corporate Services"]
    human_rights_subareas = ["Violation", "Education activities", "Office reports", "Universal periodic review", "CEDAW", "CRC", "CRPD"]
    good_governance_subareas = ["Violation", "Office report", "Office consultations"]

    areas.each do |a|
      Area.create(:name => a) unless Area.where(:name => a).exists?
    end

    human_rights_id = Area.where(:name => "Human Rights").first.id
    human_rights_subareas.each do |hrsa|
      Subarea.create(:name => hrsa, :area_id => human_rights_id) unless Subarea.where(:name => hrsa, :area_id => human_rights_id).exists?
    end

    good_governance_id = Area.where(:name => "Good Governance").first.id
    good_governance_subareas.each do |ggsa|
      Subarea.create(:name => ggsa, :area_id => good_governance_id) unless Subarea.where(:name => ggsa, :area_id => good_governance_id).exists?
    end
  end

  def setup_file_constraints
    SiteConfig['outreach_event.filetypes'] = ['pdf']
    SiteConfig['outreach_event.filesize'] = 3
  end

  def setup_strategic_plan
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    o = Outcome.create(:planned_result_id => pr.id, :description => "ultimate enlightenment")
    a1 = Activity.create(:description => "Smarter thinking", :outcome_id => o.id)
    a2 = Activity.create(:description => "Public outreach", :outcome_id => o.id)
    a3 = Activity.create(:description => "Media coverage", :outcome_id => o.id)
    p1 = PerformanceIndicator.create(:description => "Happier people", :target => "90%", :activity_id => a1.id)
    p2 = PerformanceIndicator.create(:description => "More wealth", :target => "80%", :activity_id => a2.id)
    p3 = PerformanceIndicator.create(:description => "Greater justice", :target => "70%", :activity_id => a3.id)
  end
end
