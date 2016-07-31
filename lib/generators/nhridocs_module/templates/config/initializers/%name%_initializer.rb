factory_path = Rails.root.join('vendor','gems',"<%= name %>",'spec','factories')
FactoryGirl.definition_file_paths << factory_path
