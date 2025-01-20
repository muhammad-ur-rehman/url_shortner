module Jwt
  class Decode
    def self.decode(token)
      key = Rails.application.credentials.devise_jwt_secret_key
      decoded = JWT.decode(token, key, true, { algorithm: 'HS256' })
      decoded[0] # The payload
    rescue JWT::DecodeError
      nil
    end
  end
end
