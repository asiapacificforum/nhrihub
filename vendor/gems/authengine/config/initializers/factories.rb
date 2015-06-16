if Rails.env.development? || Rails.env.test?
  factory_path = Rails.root.join('vendor','gems','authengine','spec','factories')
  FactoryGirl.definition_file_paths << factory_path
end