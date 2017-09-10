namespace :nhri do
  namespace :advisory_council do
    namespace :terms_of_reference do
      task :depopulate=> :environment do
        Nhri::AdvisoryCouncil::TermsOfReferenceVersion.destroy_all
      end

      desc "populates terms of reference"
      task :populate => "nhri:advisory_council:terms_of_reference:depopulate" do
        3.times do |i|
          FactoryGirl.create(:terms_of_reference_version, :revision_major => i+1, :revision_minor => 0)
        end
      end
    end

    namespace :membership do
      task :depopulate => :environment do
        AdvisoryCouncilMember.destroy_all
      end

      desc "populates advisory council members list"
      task :populate => "nhri:advisory_council:membership:depopulate" do
        3.times do
          FactoryGirl.create(:advisory_council_member)
        end
      end
    end

    namespace :meeting_minutes do
      task :depopulate => :environment do
        Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.destroy_all
      end

      desc "populates advisory council minutes list"
      task :populate => "nhri:advisory_council:meeting_minutes:depopulate" do
        3.times do
          FactoryGirl.create(:advisory_council_minutes)
        end
      end
    end

    namespace :issues do
      task :depopulate => :environment do
        Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.destroy_all
      end

      desc "populates advisory council issues"
      task :populate => "nhri:advisory_council:issues:depopulate" do
        20.times do
          ma = FactoryGirl.create(:advisory_council_issue, :with_reminders, :with_notes, [:hr_area, :si_area, :gg_area, :hr_violation_subarea].sample, :created_at => Date.today.advance(:days => -(rand(365))).to_datetime)
        end
      end
    end
  end
end
