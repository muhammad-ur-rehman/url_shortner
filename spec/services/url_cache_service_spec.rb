require 'rails_helper'

RSpec.describe UrlCacheService, type: :service do
  let(:url) { create(:url, original_url: 'https://example.com') } # Assuming FactoryBot is set up
  let(:cache_service) { UrlCacheService.new(url) }

  before do
    cache_service.redis.flushdb
  end

  describe '#save_to_cache' do
    it 'saves URL data to cache' do
      cache_service.save_to_cache
      expect(cache_service.redis.get(cache_service.send(:generate_cache_key_for_url_by_id, url.id))).to be_present
      expect(cache_service.redis.get(cache_service.send(:generate_cache_key_for_shortened_url, url.key))).to be_present
    end

    it 'does not save URL to cache if expiration time is invalid' do
      allow(url).to receive(:expires_at).and_return(Time.now - 1.hour)
      cache_service.save_to_cache

      expect(cache_service.redis.get(cache_service.send(:generate_cache_key_for_url_by_id, url.id))).to be_nil
    end
  end

  describe '#fetch_from_cache_using_id' do
    it 'fetches URL from cache when available' do
      cache_service.save_to_cache

      cached_data = cache_service.fetch_from_cache_using_id(url.id)

      # Normalize the timestamps to DateTime without nanoseconds
      expected_data = url.attributes.symbolize_keys
      expected_data[:created_at] = url.created_at.to_datetime.change(nsec: 0)
      expected_data[:updated_at] = url.updated_at.to_datetime.change(nsec: 0)
      expected_data[:expires_at] = url.expires_at.to_datetime.change(nsec: 0) if url.expires_at
      cached_data[:created_at] = DateTime.parse(cached_data[:created_at]).change(nsec: 0) if cached_data[:created_at]
      cached_data[:updated_at] = DateTime.parse(cached_data[:updated_at]).change(nsec: 0) if cached_data[:updated_at]
      cached_data[:expires_at] = DateTime.parse(cached_data[:expires_at]).change(nsec: 0) if cached_data[:expires_at]

      expect(cached_data).to eq(expected_data)
    end

    it 'returns nil if the URL is not in the cache' do
      cached_data = cache_service.fetch_from_cache_using_id(url.id)
      expect(cached_data).to be_nil
    end
  end

  describe '#fetch_from_cache_using_key' do
    it 'fetches URL from cache using the shortened URL key' do
      # Save URL to cache
      cache_service.save_to_cache

      cached_data = cache_service.fetch_from_cache_using_key(url.key)
      expected_data = url.attributes.symbolize_keys
      expected_data[:created_at] = url.created_at.to_datetime.change(nsec: 0)
      expected_data[:updated_at] = url.updated_at.to_datetime.change(nsec: 0)

      expected_data[:expires_at] = url.expires_at.to_datetime.change(nsec: 0) if url.expires_at

      cached_data[:created_at] = DateTime.parse(cached_data[:created_at]).change(nsec: 0) if cached_data[:created_at]
      cached_data[:updated_at] = DateTime.parse(cached_data[:updated_at]).change(nsec: 0) if cached_data[:updated_at]
      cached_data[:expires_at] = DateTime.parse(cached_data[:expires_at]).change(nsec: 0) if cached_data[:expires_at]

      expect(cached_data).to eq(expected_data)
    end

    it 'returns nil if the shortened URL key is not in the cache' do
      cached_data = cache_service.fetch_from_cache_using_key(url.key)

      expect(cached_data).to be_nil
    end
  end
end
