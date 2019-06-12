config.middleware.use(
  "Rack::Static",
  urls: ["/complaints_packs"], root: "complaints/public"
)
