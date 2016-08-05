require 'wordlist'

def rand_title
  l = rand(4)+4
  arr = []
  l.times do
    word = @words.sample
    word = word.upcase == word ? word : word.capitalize
    arr << word
  end
  arr.join(' ')
end

def rand_filename
  l = rand(3)+3
  arr = []
  l.times do
    arr << @words.sample
  end
  arr.join('_').downcase + ".pdf"
end

namespace :nhri do
  desc "populate all nhri modules"
  task :populate => [:populate_ref_docs, :populate_tor, :populate_mem, :populate_min, :populate_iss, :populate_ind_etc]

  desc "populates icc accreditation reference documents"
  task :populate_ref_docs => :environment do
    IccReferenceDocument.destroy_all
    5.times do |i|
      FactoryGirl.create(:icc_reference_document)
    end
  end


  desc "populates terms of reference"
  task :populate_tor => :environment do
    Nhri::AdvisoryCouncil::TermsOfReferenceVersion.destroy_all
    3.times do |i|
      FactoryGirl.create(:terms_of_reference_version, :revision_major => i+1, :revision_minor => 0)
    end
  end

  desc "populates advisory council members list"
  task :populate_mem => :environment do
    AdvisoryCouncilMember.destroy_all
    3.times do
      FactoryGirl.create(:advisory_council_member)
    end
  end

  desc "populates advisory council minutes list"
  task :populate_min => :environment do
    Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes.destroy_all
    3.times do
      FactoryGirl.create(:advisory_council_minutes)
    end
  end

  desc "populates advisory council issues"
  task :populate_iss => :environment do
    Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.destroy_all

    20.times do
      ma = FactoryGirl.create(:advisory_council_issue, :with_reminders, :with_notes, [:hr_area, :si_area, :gg_area, :hr_violation_subarea].sample)
    end
  end

  desc "populates indicators and related tables"
  task :populate_ind_etc => [:populate_head, :populate_off, :populate_ind]

  desc "populates headings"
  task :populate_head => :environment do
    Nhri::Heading.destroy_all
    6.times do
      FactoryGirl.create(:heading)
    end
  end

  desc "populates human_rights_attributes"
  task :populate_off => :environment do
    Nhri::HumanRightsAttribute.destroy_all
    Nhri::Heading.pluck(:id).each do |h_id|
      5.times do
        FactoryGirl.create(:human_rights_attribute, :heading_id => h_id)
      end
    end
  end

  desc "populates indicators"
  task :populate_ind => :environment do
    Nhri::Indicator.destroy_all
    Nhri::Heading.all.each do |heading|
      ["Structural", "Process", "Outcomes"].each do |nature|
        rand(4).times do
          notes = rand(3).times.collect{|i| FactoryGirl.build(:note)}
          reminders = rand(3).times.collect{|i| FactoryGirl.build(:reminder)}
          type = ["text", "numeric", "file"].sample
          case type
          when "text"
            monitors = rand(3).times.collect{|i| FactoryGirl.build(:text_monitor)}
            FactoryGirl.create(:indicator,
                               :nature => nature,
                               :human_rights_attribute_id => nil,
                               :heading_id => heading.id,
                               :notes => notes,
                               :reminders => reminders,
                               :text_monitors => monitors)
          when "numeric"
            monitors = rand(3).times.collect{|i| FactoryGirl.build(:numeric_monitor)}
            FactoryGirl.create(:indicator,
                               :nature => nature,
                               :human_rights_attribute_id => nil,
                               :heading_id => heading.id,
                               :numeric_monitor_explanation => Faker::Lorem.words(7).join(' '),
                               :notes => notes,
                               :reminders => reminders,
                               :numeric_monitors => monitors)
          else
            monitor = FactoryGirl.build(:file_monitor)
            FactoryGirl.create(:indicator,
                               :nature => nature,
                               :human_rights_attribute_id => nil,
                               :heading_id => heading.id,
                               :notes => notes,
                               :reminders => reminders,
                               :file_monitor => monitor)
          end #/case
        end #/rand(4) loop
        heading.human_rights_attributes.pluck(:id).each do |o_id|
          3.times do
            notes = rand(3).times.collect{|i| FactoryGirl.build(:note)}
            reminders = rand(3).times.collect{|i| FactoryGirl.build(:reminder)}
            type = ["text", "numeric", "file"].sample
            case type
            when "text"
              monitors = rand(3).times.collect{|i| FactoryGirl.build(:text_monitor)}
              FactoryGirl.create(:indicator,
                                 :nature => nature,
                                 :human_rights_attribute_id => o_id,
                                 :heading_id => heading.id,
                                 :notes => notes,
                                 :reminders => reminders,
                                 :text_monitors => monitors)
            when "numeric"
              monitors = rand(3).times.collect{|i| FactoryGirl.build(:numeric_monitor)}
              FactoryGirl.create(:indicator,
                                 :nature => nature,
                                 :human_rights_attribute_id => o_id,
                                 :heading_id => heading.id,
                                 :numeric_monitor_explanation => Faker::Lorem.words(7).join(' '),
                                 :notes => notes,
                                 :reminders => reminders,
                                 :numeric_monitors => monitors)
            else
              monitor = FactoryGirl.build(:file_monitor)
              FactoryGirl.create(:indicator,
                                 :nature => nature,
                                 :human_rights_attribute_id => o_id,
                                 :heading_id => heading.id,
                                 :notes => notes,
                                 :reminders => reminders,
                                 :file_monitor => monitor)
            end #/case
          end #/3.times
        end #o_id loop
      end #nature loop
    end #/Nhri::Heading
  end #/task
end #/namespace
