FactoryGirl.define do
  factory :media_appearance do
    user
    positivity_rating
    violation_severity
    title {Faker::Lorem.sentence(5)}
    affected_people_count { rand(20000) }
    violation_coefficient { (rand(100).to_f/100.to_f) }
    #after :create do |ma|
      #ma.notes << FactoryGirl.create(:note)
    #end

    trait :link do
      #article_link { Faker::Internet.url }
      article_link { "http://www.nytimes.com" }
    end

    trait :file do
      file_id             { SecureRandom.hex(30) }
      filesize            { 10000 + (30000*rand).to_i }
      original_filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
      original_type       "application/pdf"
    end

    after(:build) do |media_appearance|
      if media_appearance.file_id
        path = Rails.env.production? ?
          Rails.root.join('..','..','shared') :
          Rails.root.join('tmp')
        FileUtils.touch path.join('uploads','store',media_appearance.file_id) 
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
        ma.subareas << Subarea.where(:name => "CRC").first
        ma.save
      end
    end
  end
end
