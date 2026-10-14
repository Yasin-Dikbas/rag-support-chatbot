# Be sure to restart your server when you modify this file.
#
# Two separate policies:
# - the dashboard SPA (FRONTEND_URL) gets full API access with credentials
# - the embeddable widget is meant to run on ANY third-party site, so its
#   endpoints allow any origin but never send/accept credentials

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_URL", "http://localhost:5175")

    resource "/api/*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true
  end

  allow do
    origins "*"

    resource "/api/widget/*",
      headers: :any,
      methods: [ :get, :post, :options ],
      credentials: false
  end
end
