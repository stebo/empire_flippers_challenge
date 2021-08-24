# TODO: make sure to use use env specific API keys later
Hubspot.configure do |config|
  config.api_key['hapikey'] = Rails.application.credentials.hubspot[:api_key]
end