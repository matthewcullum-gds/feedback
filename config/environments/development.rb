Rails.application.configure do
  config.action_controller.perform_caching = false

  config.action_dispatch.best_standards_support = :builtin

  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log

  config.assets.compress = false
  config.assets.debug = true
  if ENV['GOVUK_ASSET_ROOT'].present?
    config.asset_host = ENV['GOVUK_ASSET_ROOT']
  end

  config.cache_classes = false

  config.consider_all_requests_local = true

  config.eager_load = false

  config.whiny_nils = true
end
