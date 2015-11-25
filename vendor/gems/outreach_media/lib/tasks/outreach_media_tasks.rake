# desc "Explaining what the task does"
# task :outreach_media do
#   # Task goes here
# end
areas = ["Human Rights", "Good Governance", "Special Investigations Unit", "Corporate Services"]
human_rights_subareas = ["Violation", "Education activities", "Office reports", "Universal periodic review", "CEDAW", "CRC", "CRPD"]
good_governance_subareas = ["Violation", "Office report", "Office consultations"]


desc "populate violation severity table"
task :populate_vs => :environment do
  ViolationSeverity.delete_all
  ViolationSeverity::DefaultValues.each { |vs| ViolationSeverity.create(:rank=>vs.rank, :text => vs.text) }
end

desc "populate positivity ratings"
task :populate_pr => :environment do
  PositivityRating.delete_all
  PositivityRating::DefaultValues.each { |pr| PositivityRating.create(:rank => pr.rank, :text => pr.text) }
end

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
  MediaAppearance.delete_all

  100.times do
    ma = FactoryGirl.create(:media_appearance,  [:file, :link].sample)
    area = Area.all.sample
    ma.areas << area
    unless area.subareas.empty?
      ma.subareas << area.subareas.sample(2)
    end
  end

end

