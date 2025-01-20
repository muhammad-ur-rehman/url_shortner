class SyncClickCountJob < ApplicationJob
  queue_as :default

  def perform
    shortened_url_keys.each do |key|
      next if key.include?('_click_count')

      cleaned_key = key.split('url:shortened_url:')[1]
      cached_data = url_cache_service.fetch_from_cache_using_key(cleaned_key)
      next unless cached_data

      url = Url.find_by(id: cached_data[:id])
      next unless url

      ActiveRecord::Base.transaction do
        cached_count = url_cache_service.get_click_count(cleaned_key)

        total_count = cached_count + url.click_count

        url.update!(click_count: total_count)

        UrlCacheService.new(url).save_to_cache
      end
    end
  end

  private

  def url_cache_service
    @url_cache_service ||= UrlCacheService.new(nil)
  end

  def shortened_url_keys
    url_cache_service.redis.keys('url:shortened_url:*')
  end
end
