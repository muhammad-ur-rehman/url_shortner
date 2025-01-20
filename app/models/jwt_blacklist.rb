class JwtBlacklist < ApplicationRecord
  self.table_name = 'jwt_blacklists'

  def self.blacklisted?(jti)
    where(jti: jti).exists?
  end
end
