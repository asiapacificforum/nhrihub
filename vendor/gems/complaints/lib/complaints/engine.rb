module Complaints
  class Engine < ::Rails::Engine
    initializer "complaints.webpacker.proxy" do |app|
        insert_middleware = begin
                            Complaints.webpacker.config.dev_server.present?
                          rescue
                            nil
                          end
        next unless insert_middleware

        app.middleware.insert_before(
          0, Webpacker::DevServerProxy, # "Webpacker::DevServerProxy" if Rails version < 5
          ssl_verify_none: true,
          webpacker: Complaints.webpacker
        )

      end # /initializer

      config.app_middleware.use(
        Rack::Static,
        urls: ["/complaints_packs"], root: "vendor/gems/complaints/public"
      )

  end
end
