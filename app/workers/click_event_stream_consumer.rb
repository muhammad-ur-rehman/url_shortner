# app/workers/click_event_stream_consumer.rb

class ClickEventStreamConsumer
  include Sidekiq::Worker

  STREAM_NAME = 'click_events_stream'.freeze
  GROUP_NAME = 'click_event_group'.freeze
  CONSUMER_NAME = 'click_event_consumer'.freeze

  def perform
    redis = Redis.new

    # Ensure the consumer group exists
    create_consumer_group(redis)

    # Read entries from the stream
    entries = redis.xreadgroup(GROUP_NAME, CONSUMER_NAME, STREAM_NAME, '>')
    process_entries(entries)
  rescue Redis::BaseError => e
    Rails.logger.error("Redis Stream Consumer Error: #{e.message}")
  end

  private

  def create_consumer_group(redis)
    redis.xgroup('CREATE', STREAM_NAME, GROUP_NAME, '$', mkstream: true)
  rescue Redis::CommandError => e
    Rails.logger.warn("Consumer group already exists: #{e.message}")
  end

  def process_entries(entries)
    entries.each do |_stream, messages|
      messages.each do |_id, fields|
        process_message(fields)
      end
    end
  end

  def process_message(fields)
    key = fields['key']

    url = Url.find_by(key: key)
    return unless url

    # Get cached click count
    cached_count = UrlCacheService.new(nil).get_click_count(key)
    url.increment!(:click_count, cached_count)

    # Reset the cached click count
    UrlCacheService.new(nil).reset_click_count(key)
  end
end
