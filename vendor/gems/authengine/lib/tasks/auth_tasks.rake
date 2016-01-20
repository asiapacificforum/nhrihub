desc "populate users, resetting all except those already registered"
task :populate_users => :environment do
  User.where("crypted_password is null").delete_all
  Organization.all.select{|o| o.users.count.zero?}.each{|o| o.delete}
  15.times do
    FactoryGirl.create(:user, :staff)
  end
end
