FactoryGirl.define do
  factory :media_appearance do
    user
    positivity_rating
    title {Faker::Lorem.sentence(5)}
    note {Faker::Lorem.sentences(1)}
    affected_people_count { rand(20000) }
    violation_severity { rand(5) }
    violation_coefficient { (rand(100).to_f/100.to_f) }

    trait :link do
      url { Faker::Internet.url }
    end

    trait :file do
      file_id             { SecureRandom.hex(30) }
      filesize            { 10000 + (30000*rand).to_i }
      original_filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
      original_type       "application/pdf"
    end

    trait :no_f_in_title do
      title Faker::Lorem.sentence(5).gsub(/f/i,"b")
    end

    trait :hr_area do
      after(:create) do |ma|
        ma.areas << Area.where(:name => "Human Rights").first
        ma.save
      end
    end

    trait :si_area do
      after(:create) do |ma|
        ma.areas << Area.where(:name => "Special Investigations Unit").first
        ma.save
      end
    end

    trait :gg_area do
      after(:create) do |ma|
        ma.areas << Area.where(:name => "Good Governance").first
        ma.save
      end
    end

    trait :crc_subarea do
      after(:create) do |ma|
        ma.media_areas.first.subareas << Subarea.where(:name => "CRC").first
        ma.save
      end
    end
  end
end
