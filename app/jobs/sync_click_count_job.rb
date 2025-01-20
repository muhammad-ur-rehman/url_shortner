class SyncClickCountJob < ApplicationJob
  queue_as :default

  def perform
    url_cache_service = UrlCacheService.new(nil)
    keys = url_cache_service.redis.keys('url:shortened_url:*')

    keys.each do |key|
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
end













# class SyncClickCountJob < ApplicationJob
#   queue_as :default

#   def perform
#     url_cache_service = UrlCacheService.new(nil)
#     keys = url_cache_service.redis.keys('url:shortened_url:*')

#     keys.each do |key|
#       next if key.include?('_click_count')

#       cleaned_key = key.split('url:shortened_url:')[1]
#       cached_data = url_cache_service.fetch_from_cache_using_key(cleaned_key)
#       next unless cached_data

#       # Find the corresponding database record
#       url = Url.find_by(id: cached_data[:id])
#       next unless url

#       cached_count = url_cache_service.get_click_count(cleaned_key)
#       total_count = cached_count + url.click_count
#       url.update!(click_count: total_count)
#       UrlCacheService.new(url).save_to_cache
#     end
#   end
# end
