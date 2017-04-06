Rails::Engine.subclasses.map(&:instance).each do |eng|
  app_include = false
  eng.root.ascend{|path| app_include = true if (path == Rails.root)}
  if app_include
    eng.config.mount_at = '/'
  end
end
