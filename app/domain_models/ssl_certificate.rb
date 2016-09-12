class SslCertificate
  attr_accessor :cert
  def initialize
    raw_cert = File.read(Rails.root.join('certificates',"#{SITE_URL}-cert.pem"))
    @cert = OpenSSL::X509::Certificate.new(raw_cert)
  end

  def expires_on
    cert.not_after
  end
end
