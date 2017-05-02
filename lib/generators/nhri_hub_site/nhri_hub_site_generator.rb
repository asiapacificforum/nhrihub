class NhriHubSiteGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  attr_accessor :site_name, :templates

  def init
    @site_name = file_name
    @site_path = "config/site_specific_linked_files/#{file_name}"
    @site_root = Rails.root.join @site_path
  end

  def templates
    @templates = Dir.chdir(File.expand_path('../templates',__FILE__)) do
      Dir.glob("**/*").select{|f| File.stat(f).file? }
    end
  end

  def copy_templates
    templates.each do |file_path|
      copy_file file_path, @site_root.join(file_path).to_s
    end
  end

  def gitignore
    file = Rails.root.join('.gitignore')
    unless File.read(file).match(@site_path.to_s)
      append_to_file file, @site_path.to_s
    end
  end

  def delete_me_when_youve_fixed_this
    raise "change the deploy file to a generic file from capistrano gem"
  end

end
