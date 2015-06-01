FactoryGirl.define do
  factory :role do
    name :chief_person

    factory :staff_role do
      name "staff"
    end

    factory :admin_role do
      name "admin"
    end
  end
end
