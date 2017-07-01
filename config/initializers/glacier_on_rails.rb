if defined? GlacierOnRails
  require 'glacier_on_rails/config'
  GlacierOnRails::Config.setup do |config|
    config.attached_files_directory = FileUploadLocation.join('store')
    config.aws_region = 'us-east-1'
  end

  AwsLog.logger.level = 'debug' # possible values are: 'debug', 'info', 'warn', 'error', 'fatal'
                                # 'debug' is the most liberal, 'fatal' the most restrictive
end
