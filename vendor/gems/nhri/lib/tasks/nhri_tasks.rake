# desc "Explaining what the task does"
# task :nhri do
#   # Task goes here
# end
namespace :nhri do
  desc "populate all nhri modules"
  task :populate => [:populate_tor, :populate_mem, :populate_min, :populate_iss, :populate_ind]

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
    Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.delete_all

    20.times do
      ma = FactoryGirl.create(:advisory_council_issue, :with_reminders, :with_notes, [:hr_area, :si_area, :gg_area, :hr_violation_subarea].sample)
    end
  end

  desc "populates indicators and related tables"
  task :populate_ind_etc => [:populate_head, :populate_off, :populate_ind]

  desc "populates headings"
  task :populate_head => :environment do
    Nhri::Indicator::Heading.delete_all
    i = 0
    6.times do
      i+=1
      FactoryGirl.create(:heading)
    end
    puts "h #{i}"
  end

  desc "populates offences"
  task :populate_off => :environment do
    Nhri::Indicator::Offence.delete_all
    i = 0
    Nhri::Indicator::Heading.pluck(:id).each do |h_id|
      5.times do
        i+=1
        FactoryGirl.create(:offence, :heading_id => h_id)
      end
    end
    puts "o #{i}"
  end

  desc "populates indicators"
  task :populate_ind => :environment do
    Nhri::Indicator::Indicator.delete_all
    i = 0
    Nhri::Indicator::Heading.all.each do |heading|
      ["Structural", "Process", "Outcomes"].each do |nature|
        FactoryGirl.create(:indicator, :nature => nature, :offence_id => nil, :heading_id => heading.id)
        i+=1
        heading.offences.pluck(:id).each do |o_id|
          3.times do
            i+=1
            FactoryGirl.create(:indicator, :nature => nature, :offence_id => o_id, :heading_id => heading.id)
          end
        end
      end
    end
    puts "i #{i}"
  end
end
