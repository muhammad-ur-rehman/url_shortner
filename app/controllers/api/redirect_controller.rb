module Api
class RedirectController < ApplicationController
  include FindUrlHelper

  before_action :find_url_by_id_or_key, only: [:show]

  def show
    if @url.expired?
      render_gone({ error: 'URL has expired' })
    else
      url_cache_service = UrlCacheService.new(@url)
      url_cache_service.increment_click_count
      redirect_to @url.original_url, allow_other_host: true
    end
  end
end
end
