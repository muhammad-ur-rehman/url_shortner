class Url < ApplicationRecord
  validates :original_url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :key, presence: true, uniqueness: true
  validate :expiration_date_is_valid, if: :expires_at?

  before_validation :generate_key, on: :create

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  private

  def generate_key
    if key.blank?
      self.key = loop do
        random_slug = SecureRandom.urlsafe_base64(10)
        break random_slug unless Url.exists?(key: random_slug)
      end
    elsif Url.exists?(key: key)
      errors.add(:key, 'has already been taken')
      throw :abort
    end
  end

  def expiration_date_is_valid
    errors.add(:expires_at, 'must be in the future') if expired?
    begin
      DateTime.parse(expires_at.to_s)
    rescue ArgumentError
      errors.add(:expires_at, "Must be a valid ISO 8601 datetime format (e.g., '2025-01-19 00:00:00')")
    end
  end
end
