class TwoFactorAuthentication
  def self.enabled?
    ENV.fetch("two_factor_authentication").blank? ||
      ENV.fetch("two_factor_authentication") == 'enabled'
  end

  def self.disabled?
    ENV.fetch('two_factor_authentication') == 'disabled'
  end
end
