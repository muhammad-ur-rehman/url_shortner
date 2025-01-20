require 'rails_helper'

RSpec.describe SyncClickCountJob, type: :job do
  let!(:url) { create(:url, original_url: 'https://example.com', click_count: 10) }
  let!(:url_cache_service) { UrlCacheService.new(url) }

  before do
    url_cache_service.redis.flushdb
    url_cache_service.save_to_cache
  end

  describe '#perform' do
    it 'fetches click count from cache and updates the database' do
      url_cache_service.increment_click_count

      SyncClickCountJob.perform_now

      url.reload

      expect(url.click_count).to eq(11)
    end

    it 'does not update the database if there is no corresponding cache' do
      url_cache_service.redis.del(url_cache_service.send(:generate_cache_key_for_shortened_url, url.key))

      SyncClickCountJob.perform_now
      url.reload
      expect(url.click_count).to eq(10)
    end

    it 'saves the updated URL back to cache after updating the click count' do
      url_cache_service.increment_click_count
      SyncClickCountJob.perform_now
      cached_data = url_cache_service.fetch_from_cache_using_key(url.key)

      expect(cached_data[:click_count]).to eq(11)
    end

    it 'skips invalid URLs or cache entries gracefully' do
      allow(url_cache_service).to receive(:fetch_from_cache_using_key).and_return(nil)

      expect { SyncClickCountJob.perform_now }.not_to raise_error

      url.reload
      expect(url.click_count).to eq(10)
    end
  end
end
