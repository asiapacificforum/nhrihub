if defined? GetBack
  require 'get_back/config'
  GetBack::Config.setup do |config|
    config.attached_files_directory = FileUploadLocation.join('store')
  end

  AwsLog.logger.level = 'debug' # possible values are: 'debug', 'info', 'warn', 'error', 'fatal'
                                # 'debug' is the most liberal, 'fatal' the most restrictive
end
