class UrlCacheService
  URL_CACHE_TIME = 12.hours

  def initialize(url)
    @url = url
    @redis_key = generate_cache_key_for_url_by_id(@url.id) if url.present?
  end

  def fetch_from_cache_using_id(id)
    cached_data = redis.get(generate_cache_key_for_url_by_id(id))
    parse_cached_data(cached_data)
  end

  def fetch_from_cache_using_key(key)
    redis_shortened_key = generate_cache_key_for_shortened_url(key)
    cached_data = redis.get(redis_shortened_key)
    parse_cached_data(cached_data)
  end

  def save_to_cache
    return unless @url

    expiration_time = calculate_expiration_time
    if expiration_time <= 0
      Rails.logger.warn("Skipping cache for URL #{@url.id}: Expiration time is invalid or expired.")
      return
    end

    save_for_id(expiration_time)
    save_for_key(expiration_time)
    save_click_count(expiration_time)
  end

  def validate_expires_at(date_time)
    return unless date_time

    DateTime.parse(date_time.to_s)
  rescue ArgumentError
    raise ArgumentError, 'Expires at must be a valid ISO 8601 datetime format'
  end

  def get_click_count(key = nil)
    available_key = @url&.key || key
    redis.hget(click_count_key(available_key), 'click_count').to_i
  end

  def reset_click_count(key = nil)
    available_key = @url&.key || key
    complete_key = click_count_key(available_key)
    expiration_time = redis.ttl(complete_key)

    if expiration_time >= 0
      redis.hset(complete_key, 'click_count', 0)
      redis.expire(complete_key, expiration_time)
    else
      Rails.logger.warn("Cannot reset click_count for #{key}. Key not found or has no expiration.")
    end
  end

  def increment_click_count(key = nil)
    available_key = @url&.key || key
    complete_key = click_count_key(available_key)
    redis.hincrby(complete_key, 'click_count', 1)
  end

  def redis
    @redis ||= Redis.new
  end

  private

  def parse_cached_data(cached_data)
    return nil unless cached_data

    JSON.parse(cached_data, symbolize_names: true)
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse cached data: #{e.message}")
    nil
  end

  def calculate_expiration_time
    @url.expires_at? ? (@url.expires_at - Time.now).to_i : URL_CACHE_TIME
  end

  def save_for_id(expiration_time)
    if expiration_time.positive?
      redis.setex(@redis_key, expiration_time, @url.to_json)
    else
      Rails.logger.warn("Invalid expiration time for key #{@redis_key}. Key will not be saved.")
    end
  end

  def save_for_key(expiration_time)
    key = generate_cache_key_for_shortened_url(@url.key)
    if expiration_time.positive?
      redis.setex(key, expiration_time, @url.to_json)
    else
      Rails.logger.warn("Invalid expiration time for key #{key}. Key will not be saved.")
    end
  end

  def save_click_count(expiration_time)
    key = click_count_key(@url.key)

    redis.hset(key, 'click_count', 0)
    redis.expire(key, expiration_time)
  end

  def click_count_key(key)
    "url:shortened_url:#{key}_click_count"
  end

  def generate_cache_key_for_shortened_url(key)
    "url:shortened_url:#{key}"
  end

  def generate_cache_key_for_url_by_id(url_id)
    "url:#{url_id}"
  end
end
