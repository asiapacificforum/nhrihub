SecureHeaders::Configuration.default do |config|
  config.cookies = {
    secure: true, # mark all cookies as "Secure"
    httponly: true, # mark all cookies as "HttpOnly"
    samesite: {
      lax: true # mark all cookies as SameSite=lax
    }
  }
  config.hsts = "max-age=#{20.years.to_i}; includeSubdomains; preload"
  #config.x_frame_options = "DENY"
  # because DENY caused the actionmailer#preview not to be rendered
  config.x_frame_options = "SAMEORIGIN"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = "origin-when-cross-origin"
  #config.csp = {
    # "meta" values. these will shaped the header, but the values are not included in the header.
    #report_only: true,      # default: false [DEPRECATED from 3.5.0: instead, configure csp_report_only]
    #preserve_schemes: true, # default: false. Schemes are removed from host sources to save bytes and discourage mixed content.

    ## directive values: these values will directly translate into source directives
    #default_src: %w(https: 'self'),
    #base_uri: %w('self'),
    #block_all_mixed_content: true, # see http://www.w3.org/TR/mixed-content/
    #child_src: %w('self'), # if child-src isn't supported, the value for frame-src will be set.
    #connect_src: %w(wss:),
    #font_src: %w('self' data:),
    #form_action: %w('self' github.com),
    #frame_ancestors: %w('none'),
    #img_src: %w(mycdn.com data:),
    #media_src: %w(utoob.com),
    #object_src: %w('self'),
    #plugin_types: %w(application/x-shockwave-flash),
    #script_src: %w('self'),
    #style_src: %w('unsafe-inline'),
    #upgrade_insecure_requests: true, # see https://www.w3.org/TR/upgrade-insecure-requests/
    #report_uri: %w(https://report-uri.io/example-csp)
  #}
  config.csp = {
    :connect_src => %w('self' ws://localhost:3035 wss://localhost:3035 http://localhost:3035), # localhost:3035 used by webpacker for chrome live update
    :default_src => %w(https: 'self'),
    :script_src => %w('self' 'unsafe-inline' 'unsafe-eval'),
    :img_src => %w('self' data:),
    :style_src => %w('self' 'unsafe-inline'),
    :report_uri => %W(/#{Rails.application.config.i18n.default_locale.to_s}/csp_reports)
  }
  
  # This is available only from 3.5.0; use the `report_only: true` setting for 3.4.1 and below.
  #config.csp_report_only = config.csp.merge({
    #img_src: %w(somewhereelse.com),
    #report_uri: %w(https://report-uri.io/example-csp-report-only)
  #})
  #config.hpkp = {
    #report_only: false,
    #max_age: 60.days.to_i,
    #include_subdomains: true,
    #report_uri: "https://report-uri.io/example-hpkp",
    #pins: [
      #{sha256: "abc"},
      #{sha256: "123"}
    #]
  #}
end

