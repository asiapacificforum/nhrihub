class SslCertificate
  attr_accessor :cert
  def initialize
    raw_cert = File.read(Rails.root.join('certificates',"#{SITE_URL}-cert.pem"))
    @cert = OpenSSL::X509::Certificate.new(raw_cert)
  rescue Errno::ENOENT
    @cert = OpenStruct.new(:not_after => "certificate not available")
  end

  def expires_on
    cert.not_after
  end
end
