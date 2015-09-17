require 'rspec/core/shared_context'

module MediaSpecHelpers
  extend RSpec::Core::SharedContext

  def setup_positivity_ratings
    PositivityRating.create({:rank => 1, :text => "Reflects very negatively on the office"})
    PositivityRating.create({:rank => 2, :text => "Reflects slightly negatively on the office"})
    PositivityRating.create({:rank => 3, :text => "Has no bearing on the office"})
    PositivityRating.create({:rank => 4, :text => "Reflects slightly positively on the office"})
    PositivityRating.create({:rank => 5, :text => "Reflects very positively on the office"})
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

  def open_reminders_panel
    reminders_icon.click
  end

  def reminders_icon
    page.find(".row.media_appearance div.actions div.alarm_icon")
  end
end
