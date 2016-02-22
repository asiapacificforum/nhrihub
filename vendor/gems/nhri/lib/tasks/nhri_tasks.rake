# desc "Explaining what the task does"
# task :nhri do
#   # Task goes here
# end
namespace :nhri do
  desc "populate all nhri modules"
  task :populate => [:populate_tor]

  desc "populates terms of reference"
  task :populate_tor => :environment do
    3.times do |i|
      FactoryGirl.create(:terms_of_reference_version, :revision_major => i+1, :revision_minor => 0)
    end
  end
end
