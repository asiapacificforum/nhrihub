# desc "Explaining what the task does"
# task :nhri do
#   # Task goes here
# end
namespace :nhri do
  desc "populate all nhri modules"
  task :populate => [:populate_tor, :populate_mem, :populate_min, :populate_iss]

  desc "populates terms of reference"
  task :populate_tor => :environment do
    Nhri::AdvisoryCouncil::TermsOfReferenceVersion.delete_all
    3.times do |i|
      FactoryGirl.create(:terms_of_reference_version, :revision_major => i+1, :revision_minor => 0)
    end
  end

  desc "populates advisory council members list"
  task :populate_mem => :environment do
    AdvisoryCouncilMember.delete_all
    3.times do
      FactoryGirl.create(:advisory_council_member)
    end
  end

  desc "populates advisory council minutes list"
  task :populate_min => :environment do
    Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.delete_all
    3.times do
      FactoryGirl.create(:advisory_council_minutes)
    end
  end

  desc "populates advisory council issues"
  task :populate_iss => :environment do
    AdvisoryCouncilIssue.delete_all

    20.times do
      ma = FactoryGirl.create(:advisory_council_issue, :with_reminders, :with_notes, [:hr_area, :si_area, :gg_area, :hr_violation_subarea].sample)
    end
  end

end
