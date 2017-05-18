if defined? GetBack
  require 'get_back/config'
  GetBack::Config.setup do |config|
    config.include_dirs = [FileUploadLocation.join('store')]
  end
end
