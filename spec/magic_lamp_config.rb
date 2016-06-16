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

