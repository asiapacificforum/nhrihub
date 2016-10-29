Dir[Rails.root.join("vendor","gems","**","spec","javascripts","**","magic_lamp.rb")].each do |lampfile|
  load lampfile
end
