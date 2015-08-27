FactoryGirl.define do
  factory :media_appearance do
    user
    positivity_rating
    title {Faker::Lorem.sentence(5)}
    description {{"areas" => [{:name => "Human rights",
                                :subareas => [ "Violation",
                                               "Education activities",
                                               "Office reports",
                                               "Universal periodic review",
                                               "CEDAW",
                                               "CRC",
                                               "CRPD" ]
                                },
                                {:name =>"Good Governance",
                                 :subareas => ["Violation",
                                               "Office report",
                                               "Office consultations"]
                                }
                               ]
                    }}
    note {Faker::Lorem.sentences(1)}
    affected_people_count { rand(20000) }
    violation_severity { rand(5) }
    violation_coefficient { (rand(100).to_f/100.to_f) }
  end

  trait :link do
    url { Faker::Internet.url }
  end

  trait :file do
    file_id             { SecureRandom.hex(30) }
    filesize            { 10000 + (30000*rand).to_i }
    original_filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
    original_type       "application/pdf"
  end
end
