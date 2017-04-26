# invoke with rake "nhri_hub:localize[au]" including the quotes and no extra spaces
namespace :nhri_hub do
  desc "on development machine, link capistrano linked files to the config/site_specific_linked_files/<% site %> files"
  task :localize,[:site] do |t,args|
    site = args[:site]
    config =  `cap #{site} deploy:print_config_variables | grep linked_files`
    # ":linked_files => [\"filename\",...]"
    files = config.match(/\[(.*)\]/)[1].split(',').map{|s| s.gsub("\"","").strip }
    #puts files
    # if file exists, and it's not a symlink, do nothing
    # if file doesn't exist or it's a symlink, link to the site_specific file
    files.each do |file|
      file_path = Rails.root.join("config/site_specific_linked_files/#{site}",file)
      link_path = Rails.root.join(file)
      if File.exists? file_path
        begin
          FileUtils.rm link_path
        rescue Errno::ENOENT
          # in case the link was not present, no need to remove it!
        end
        File.symlink file_path, link_path
      else
        puts "#{file} not found"
      end #/if
    end #/do
    config_file = Rails.root.join("config/site_specific_linked_files/current_config.yml")
    if File.exists?(config_file)
      config = YAML.load_file(config_file)
      puts "previous build was for site: #{config[:current]}"
    else
      puts "no previous build existed"
    end
    File.write(config_file, YAML.dump({:current => site}), nil, :mode => 'w')
    puts "current build is for site: #{site}"
  end #/task

  desc "creates the directory structure within config/site_specific_linked_files for a new site called with rake \"nhri_hub:create_site[oz]\""
  task :create_site,[:site] do |t,args|
    site = args[:site]
    dir = Rails.root.join('config','site_specific_linked_files',site)
    if File.exists?(dir)
      puts "site directory already exists #{dir}"
    else
      config =  `cap #{site} deploy:print_config_variables | grep linked_files`
      files = config.match(/\[(.*)\]/)[1].split(',').map{|s| s.gsub("\"","").strip }
      dirs = files.map{|f| Rails.root.join('config','site_specific_linked_files',site,f).dirname }
      dirs.uniq.each{ |dir| FileUtils.makedirs(dir) }
    end
  end
end #/namespace
