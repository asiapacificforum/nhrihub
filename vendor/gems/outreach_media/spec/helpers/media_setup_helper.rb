require 'rspec/core/shared_context'

module MediaSetupHelper
  extend RSpec::Core::SharedContext
  def setup_database(type)
    setup_areas
    if type == :media_appearance_with_file
      FactoryGirl.create(:media_appearance,
                         :hr_area,
                         :file,
                         :reminders=>[] )
    elsif type == :media_appearance_with_link
      FactoryGirl.create(:media_appearance,
                         :hr_area,
                         :link,
                         :reminders=>[] )
    else
      FactoryGirl.create(:media_appearance,
                         :hr_area,
                         :reminders=>[] )
    end
    add_reminder
  end

  def add_a_second_article
    FactoryGirl.create(:media_appearance,
                       :hr_area,
                       :reminders=>[] )
  end

  def add_reminder
    ma = MediaAppearance.first
    ma.reminders << FactoryGirl.create(:reminder, :reminder_type => 'weekly', :text => "don't forget the fruit gums mum", :user => User.first)
    ma.save
  end

  def setup_articles
    FactoryGirl.create(:media_appearance)
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
    SiteConfig['media_appearance.filetypes'] = ['pdf']
    SiteConfig['media_appearance.filesize'] = 3
  end

  def setup_strategic_plan
    sp = StrategicPlan.create(:created_at => 6.months.ago.to_date, :title => "a plan for the millenium")
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
