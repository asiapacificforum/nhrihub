# desc "Explaining what the task does"
# task :nhri do
#   # Task goes here
# end
namespace :nhri do
  desc "populate all nhri modules"
  task :populate => [:populate_tor, :populate_mem]

  desc "populates terms of reference"
  task :populate_tor => :environment do
    TermsOfReferenceVersion.delete_all
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
end
