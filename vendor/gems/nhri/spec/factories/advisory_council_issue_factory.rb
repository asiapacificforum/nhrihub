FactoryGirl.define do
  factory :advisory_council_issue, :class => Nhri::AdvisoryCouncil::AdvisoryCouncilIssue do
    title {Faker::Lorem.sentence(5)}
    #affected_people_count
    #violation_coefficient
    #positivity_rating_id
    #violation_severity_id
    #lastModifiedDate

    trait :link do
      #article_link { Faker::Internet.url }
      article_link { "http://www.nytimes.com" } # so we can actually test it!
    end

    trait :file do
      file_id             { SecureRandom.hex(30) }
      filesize            { 10000 + (30000*rand).to_i }
      original_filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
      original_type       "application/pdf"
    end

    after(:build) do |advisory_council_issue|
      advisory_council_issue.user_id = User.pluck(:id).sample
      advisory_council_issue.positivity_rating_id = PositivityRating.pluck(:id).sample
      if advisory_council_issue.file_id
        path = Rails.env.production? ?
          Rails.root.join('..','..','shared') :
          Rails.root.join('tmp')
        FileUtils.touch path.join('uploads','store',advisory_council_issue.file_id) 
      end
    end

    trait :no_f_in_title do
      title Faker::Lorem.sentence(5).gsub(/f/i,"b")
    end

    trait :title_has_an_f do
      str = Faker::Lorem.sentence(5)
      i = rand(str.length)
      l = str.length
      title { new_str = (str.dup.slice(0,i-1)+'f'+str.dup.slice(i-l,1000)).dup }
    end

    trait :hr_area do
      after(:build) do |aci|
        hr_area = Area.where(:name => "Human Rights").first
        aci.areas << hr_area
        subareas = Subarea.where(:area_id => hr_area.id).where.not(:name => "Violation")
        aci.subareas = subareas.sample(rand(6))
      end
    end

    trait :si_area do
      after(:build) do |aci|
        aci.areas << Area.where(:name => "Special Investigations Unit").first
      end
    end

    trait :gg_area do
      after(:build) do |aci|
        aci.areas << Area.where(:name => "Good Governance").first
      end
    end

    trait :crc_subarea do
      after(:build) do |aci|
        aci.subareas << Subarea.where(:name => "CRC").first
      end
    end

    trait :with_notes do
      after(:create) do |oe|
        rand(3).times do
          FactoryGirl.create(:note, :media_appearance, :notable_id => oe.id)
        end
      end
    end

    trait :with_reminders do
      after(:create) do |oe|
        rand(3).times do
          FactoryGirl.create(:reminder, :media_appearance, :remindable_id => oe.id)
        end
      end
    end

    trait :hr_violation_subarea do
      after(:build) do |aci|
        hr_area = Area.where(:name => "Human Rights").first
        aci.areas << hr_area
        aci.subareas << Subarea.where(:name => "Violation", :area_id => hr_area.id).first
        unless aci.affected_people_count
          aci.affected_people_count = rand(9000)
        end
        aci.violation_severity_id = ViolationSeverity.pluck(:id).sample
      end
    end
  end
end
