class User < ApplicationRecord
  devise :database_authenticatable, :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }
end
