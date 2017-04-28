def cap_config(site)
  instance_variable_set("@cap_config_#{site}",instance_variable_get("@cap_config_#{site}") || `cap #{site} deploy:print_config_variables`)
  instance_variable_get("@cap_config_#{site}")
end
def linked_files(site)
  config =  cap_config(site).match(/linked_files.*$/)[0]
  # ":linked_files => [\"filename\",...]"
  raise "No Capistrano linked files configured" if config.blank?
  files = config.match(/\[(.*)\]/)[1].split(',').map{|s| s.gsub("\"","").strip }
  files.map do |file|
    file_path = Rails.root.join("config/site_specific_linked_files/#{site}",file)
    link_path = Rails.root.join(file)
    [file_path, link_path, file]
  end
end
def deploy_to(site)
  deploy_path = cap_config(site).match(/deploy_to => "(.*)"$/)[1]
  shared_path = deploy_path+"/shared/"
end
# invoke with rake "nhri_hub:localize[au]" including the quotes and no extra spaces
namespace :nhri_hub do
  desc "during development pull linked files from servers, shared directory, into config/site_specific_linked_files/%site%/"
  task :fetch_linked_files do
    ["ws", "demo"].each do |site|
      puts "fetching #{site}"
      server_path = deploy_to(site)
      linked_files(site).each do |linked_file|
        file_path, link_path, file = linked_file
        puts "fetching #{file}"
        `scp #{site}:#{server_path}#{file} #{file_path}`
      end
    end
  end

  desc "check that the build has been completed for the current capistrano stage"
  task :ensure_build,[:role] do |t,args|
    stage = args[:role]
    build_site = YAML.load_file(Rails.root.join('config','site_specific_linked_files', 'current_config.yml'))[:current]
    raise "build has not been done for #{stage}" unless build_site == stage
  end

  desc "upload linked files to server"
  task :upload_linked_files,[:site] do |t,args|
    site = args[:site]
    linked_files(site).each do |file|
      file_path, link_path, file = file
      `scp #{file_path} #{site}:#{deploy_to(site)}#{file}`
    end
  end

  desc "on development machine, link capistrano linked files to the config/site_specific_linked_files/<% site %> files"
  task :localize,[:site] do |t,args|
    site = args[:site]
    linked_files(site).each do |file|
      file_path, link_path = file
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
