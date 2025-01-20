module FindUrlHelper
  extend ActiveSupport::Concern
  include Respondable

  def find_url_by_id_or_key
    cached_url = fetch_cached_url

    if cached_url
      @url = Url.new(cached_url)
    else
      @url = find_url_in_db

      if @url
        cache_service = UrlCacheService.new(@url)
        cache_service.save_to_cache
      else
        render_not_found({ error: 'URL not found' })
        nil
      end
    end
  end

  private

  def fetch_cached_url
    if params[:id]
      UrlCacheService.new(nil).fetch_from_cache_using_id(params[:id])
    elsif params[:short_url]
      UrlCacheService.new(nil).fetch_from_cache_using_key(params[:short_url])
    end
  end

  def find_url_in_db
    if params[:id]
      Url.find_by(id: params[:id])
    elsif params[:short_url]
      Url.find_by(key: params[:short_url])
    end
  end
end
