Rails::Engine.subclasses.map(&:instance).each do |eng|
  app_include = false
  # include only engines under Rails.root
  eng.root.ascend{|path| app_include = true if (path == Rails.root)}
  if app_include
    FactoryGirl.definition_file_paths += Dir.glob(eng.root.join("**/factories"))
    eng.config.mount_at = '/'
  end
end
