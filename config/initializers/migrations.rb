# instead of duplicating this in each engine
# collect all the engine migrations here:
Rails::Engine.subclasses.map(&:instance).each do |eng|
  app_include = false
  eng.root.ascend{|path| app_include = true if (path == Rails.root)}
  if app_include
    eng.config.paths["db/migrate"].expanded.each do |expanded_path|
      Rails.application.config.paths["db/migrate"] << expanded_path
    end
  end
end
