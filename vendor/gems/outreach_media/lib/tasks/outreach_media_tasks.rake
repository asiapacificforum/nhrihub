areas = ["Human Rights", "Good Governance", "Special Investigations Unit", "Corporate Services"]
human_rights_subareas = ["Violation", "Education activities", "Office reports", "Universal periodic review", "CEDAW", "CRC", "CRPD"]
good_governance_subareas = ["Violation", "Office report", "Office consultations"]


desc "populate violation severity table"
task :populate_vs => :environment do
  ViolationSeverity.delete_all
  ViolationSeverity::DefaultValues.each { |vs| ViolationSeverity.create(:rank=>vs.rank) }
end

desc "populate positivity ratings"
task :populate_pr => :environment do
  PositivityRating.delete_all
  PositivityRating::DefaultValues.each { |pr| PositivityRating.create(:rank => pr.rank) }
end

desc "populate impact ratings"
task :populate_ir => :environment do
  ImpactRating.delete_all
  ImpactRating::DefaultValues.each { |ir| ImpactRating.create(ir.marshal_dump) }
end

desc "populate audience types"
task :populate_at => :environment do
  AudienceType.delete_all
  AudienceType::DefaultValues.each { |at| AudienceType.create(at.marshal_dump) }
end

desc "populates areas and subareas"
task :populate_areas => :environment do
  Area.delete_all
  Subarea.delete_all
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
  Organization.delete_all

  20.times do
    ma = FactoryGirl.create(:media_appearance, :with_reminders, :with_notes, [:file, :link].sample, [:hr_area, :si_area, :gg_area, :hr_violation_subarea].sample)
  end

end


desc "populates outreach events with examples"
task :populate_outreach => :environment do
  OutreachEvent.delete_all

  20.times do
    oe = FactoryGirl.create(:outreach_event, :with_reminders, :with_notes, [:hr_area, :si_area, :gg_area, :hr_violation_subarea].sample)
  end
end
