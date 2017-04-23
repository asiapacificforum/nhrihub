namespace :nhri do
  namespace :advisory_council do
    desc "populates terms of reference"
    task :terms_of_reference=> :environment do
      puts "terms of ref"
      Nhri::AdvisoryCouncil::TermsOfReferenceVersion.destroy_all
      3.times do |i|
        FactoryGirl.create(:terms_of_reference_version, :revision_major => i+1, :revision_minor => 0)
      end
    end

    desc "populates advisory council members list"
    task :membership => :environment do
      puts "membership"
      AdvisoryCouncilMember.destroy_all
      3.times do
        FactoryGirl.create(:advisory_council_member)
      end
    end

    desc "populates advisory council minutes list"
    task :meeting_minutes => :environment do
      puts "minutes"
      Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.destroy_all
      3.times do
        FactoryGirl.create(:advisory_council_minutes)
      end
    end

    desc "populates advisory council issues"
    task :issues => :environment do
      puts "issues"
      Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.destroy_all

      20.times do
        ma = FactoryGirl.create(:advisory_council_issue, :with_reminders, :with_notes, [:hr_area, :si_area, :gg_area, :hr_violation_subarea].sample)
      end
    end
  end
end
