str_generator = Proc.new{
  str = Faker::Lorem.sentence(5)
  l = str.length
  i = rand(l+1)
  (str.dup.slice(0,i-1)+'f'+str.dup.slice(i-l,1000)).dup
}

audience_type_ids = AudienceType.pluck(:id)

performance_indicator_ids = PerformanceIndicator.pluck(:id)

FactoryGirl.define do
  factory :outreach_event do
    impact_rating
    title {Faker::Lorem.sentence(5)}
    participant_count { rand(2000) }
    audience_name { Faker::Lorem.words(2).join(' ') }
    audience_type_id { audience_type_ids.sample }
    event_date { Date.today.advance(:days => -rand(2000)) }
    description { Faker::Lorem.sentences(2).join(' ') }

    after(:create) do |oe|
      oe.performance_indicator_ids = performance_indicator_ids.sample(rand(2))
      oe.save
      FactoryGirl.create(:outreach_event_document, :outreach_event_id => oe.id)
    end

    trait :with_notes do
      after(:create) do |oe|
        rand(3).times do
          FactoryGirl.create(:note, :outreach_event, :notable_id => oe.id)
        end
      end
    end

    trait :with_reminders do
      after(:create) do |oe|
        rand(3).times do
          FactoryGirl.create(:reminder, :outreach_event, :remindable_id => oe.id)
        end
      end
    end

    trait :police_audience_type do
      audience_type AudienceType.where(:long_type => 'Police').first
    end

    trait :schools_audience_type do
      audience_type AudienceType.where(:long_type => 'Schools').first
    end

    trait :no_f_in_title do
      title Faker::Lorem.sentence(5).gsub(/f/i,"b")
    end

    trait :title_has_an_f do
      title {str_generator.call}
    end

    trait :hr_area do
      after(:build) do |ma|
        hr_area = Area.where(:name => "Human Rights").first
        ma.areas << hr_area
        subareas = Subarea.where(:area_id => hr_area.id).where.not(:name => "Violation")
        ma.subareas = subareas.sample(rand(6))
      end
    end

    trait :si_area do
      after(:create) do |oe|
        oe.areas << Area.where(:name => "Special Investigations Unit").first
        oe.save
      end
    end

    trait :gg_area do
      after(:create) do |oe|
        oe.areas << Area.where(:name => "Good Governance").first
        oe.save
      end
    end

    trait :crc_subarea do
      after(:create) do |oe|
        oe.subareas << Subarea.where(:name => "CRC").first
        oe.save
      end
    end

    trait :violation_subarea do
      after(:create) do |oe|
        oe.subareas << Subarea.where(:name => "Violation").first
        oe.save
      end
    end

    trait :ir_min do
      impact_rating ImpactRating.first
    end

    trait :ir_not_min do
      impact_rating ImpactRating.last
    end

    trait :hr_violation_subarea do
      after(:build) do |ma|
        hr_area = Area.where(:name => "Human Rights").first
        ma.areas << hr_area
        ma.subareas << Subarea.where(:name => "Violation", :area_id => hr_area.id).first
        ma.affected_people_count = rand(9000)
      end
    end
  end
end

