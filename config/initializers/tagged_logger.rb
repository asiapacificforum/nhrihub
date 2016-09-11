class TaggedLogger
  def self.extract_user_id_from_request(req)
    session_key = Rails.application.config.session_options[:key]
    session_data = req.cookie_jar.encrypted[session_key]
    session_data["user_id"]
    rescue
      "anon"
  end
end
