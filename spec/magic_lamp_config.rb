#Dir[OutreachMedia::Engine.root.join("spec", "support", "magic_lamp_helpers/**/*.rb")].each { |f| load f }
#Dir[OutreachMedia::Engine.root.join("spec", "javascripts", "magic_lamp", "magic_lamp.rb")].each { |f| load f }
#load OutreachMedia::Engine.root.join("spec", "javascripts", "magic_lamp", "magic_lamp.rb")
#load CorporateServices::Engine.root.join("spec", "javascripts", "magic_lamp", "magic_lamp.rb")

require "database_cleaner"

MagicLamp.configure do |config|

  DatabaseCleaner[:active_record,:connection => :jstest].strategy = :truncation

  config.before_each do
    DatabaseCleaner[:active_record,:connection => :jstest].start
  end

  config.after_each do
    DatabaseCleaner[:active_record,:connection => :jstest].clean
  end
end

