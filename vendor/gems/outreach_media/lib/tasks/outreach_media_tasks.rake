# desc "Explaining what the task does"
# task :outreach_media do
#   # Task goes here
# end
areas = ["Human Rights", "Good Governance", "Special Investigations Unit", "Corporate Services"]
human_rights_subareas = ["Violation", "Education activities", "Office reports", "Universal periodic review", "CEDAW", "CRC", "CRPD"]
good_governance_subareas = ["Violation", "Office report", "Office consultations"]

desc "populates areas and subareas"
task :populate_areas => :environment do
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

desc "populates media appearances with examples"
task :populate_media => :environment do
  hr_area = Area.where(:name => "Human Rights").first
  gg_area = Area.where(:name => "Good Governance").first

  # media appearance with human rights and good governance area with all subareas
  ma = FactoryGirl.create(:media_appearance)
  ma.areas << hr_area
  ma.areas << gg_area
  hr_media_area = MediaArea.where(:media_appearance_id => ma.id, :area_id => hr_area.id).first
  gg_media_area = MediaArea.where(:media_appearance_id => ma.id, :area_id => gg_area.id).first
  hr_media_area.subareas << Subarea.where(:area_id => hr_area.id)
  gg_media_area.subareas << Subarea.where(:area_id => gg_area.id)


  # media appearance with human rights area with all subareas
  ma = FactoryGirl.create(:media_appearance)
  ma.areas << hr_area
  hr_media_area = MediaArea.where(:media_appearance_id => ma.id, :area_id => hr_area.id).first
  hr_media_area.subareas << Subarea.where(:area_id => hr_area.id)


  # media appearance with good governance area with all subareas
  ma = FactoryGirl.create(:media_appearance)
  ma.areas << gg_area
  gg_media_area = MediaArea.where(:media_appearance_id => ma.id, :area_id => gg_area.id).first
  gg_media_area.subareas << Subarea.where(:area_id => gg_area.id)

  # media appearance with other areas and no subareas
  areas = ["Human Rights", "Good Governance", "Special Investigations Unit", "Corporate Services"].each do |a|
    ma = FactoryGirl.create(:media_appearance)
    ma.areas << Area.where(:name => a).first
  end
end

