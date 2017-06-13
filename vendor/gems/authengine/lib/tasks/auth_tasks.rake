namespace :users do
  desc "populate users, resetting all except those already registered"
  task :populate => "users:depopulate" do
    if (uc = User.count) < 20
      (20 - uc).times do
        FactoryGirl.create(:user, :staff)
      end
    end
  end

  desc "depopulate users, resetting all except those already registered"
  task :depopulate => :environment do
    User.all.select{|u| u.roles.empty? }.each{|u| u.destroy }
    User.all.select{|u| u.sessions.empty? }.each{|u| u.destroy }
    Organization.all.select{|o| o.users.count.zero?}.each{|o| o.delete}
  end
end
