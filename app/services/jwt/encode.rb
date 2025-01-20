module Jwt
  class Encode
    def self.encode(payload)
      expiration = 24.hours.from_now.to_i
      payload[:exp] = expiration
      key = Rails.application.credentials.devise_jwt_secret_key
      JWT.encode(payload, key, 'HS256')
    end
  end
end
