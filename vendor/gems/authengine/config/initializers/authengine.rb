if Rails.env.development? || Rails.env.test?
  factory_path = Rails.root.join('vendor','gems','authengine','lib','authengine','testing_support','factories')
  FactoryGirl.definition_file_paths << factory_path
end
