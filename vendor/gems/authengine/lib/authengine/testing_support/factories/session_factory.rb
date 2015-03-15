FactoryGirl.define do
  factory :session do
    association :user
    login_date { Time.now }
    session_id { Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join ) }
  end
end
