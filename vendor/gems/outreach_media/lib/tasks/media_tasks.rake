areas = ["Human Rights", "Good Governance", "Special Investigations Unit", "Corporate Services"]
human_rights_subareas = ["Violation", "Education activities", "Office reports", "Universal periodic review", "CEDAW", "CRC", "CRPD"]
good_governance_subareas = ["Violation", "Office report", "Office consultations"]

namespace :media do
  desc "populate violation severity table"

  desc "populate positivity ratings"

  desc "populate impact ratings"
  task :populate_ir => :environment do
    ImpactRating.destroy_all
    ImpactRating::DefaultValues.each { |ir| ImpactRating.create(ir.marshal_dump) }
  end

  desc "populates areas and subareas"
  task :populate_areas => :environment do
    Area.destroy_all
    Subarea.destroy_all
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
    MediaAppearance.destroy_all

    20.times do
      FactoryGirl.create(:media_appearance, :with_reminders, :with_notes, [:file, :link].sample, [:hr_area, :si_area, :gg_area, :hr_violation_subarea].sample)
    end

  end

  desc "populate both media, including dependencies"
  task :populate => :environment do
    Rake::Task["populate_users"].invoke
    Rake::Task["corporate_services:populate_sp"].invoke
    Rake::Task["media:populate_ir"].invoke
    Rake::Task["media:populate_areas"].invoke
    Rake::Task["media:populate_media"].invoke
  end
end
