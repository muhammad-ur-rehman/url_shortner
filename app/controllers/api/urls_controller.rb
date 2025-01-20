module Api
  class UrlsController < ApplicationController
    include UrlValidatable
    include FindUrlHelper

    before_action :find_url_by_id_or_key, only: [:show]

    def create
      url = Url.new(url_params)
      cache_service = UrlCacheService.new(url)

      if url.save
        cache_service.save_to_cache
        render_created(url)
      else
        render_unprocessable_entity(url.errors.full_messages)
      end
    end

    def index
      urls = Url.page(params[:page]).per(params[:per_page] || 10)

      response = {
        data: ActiveModelSerializers::SerializableResource.new(urls, each_serializer: UrlSerializer).as_json,
        metadata: pagination_metadata(urls)
      }

      render_okay(response)
    end

    def show
      render_okay(@url)
    end

    private

    def url_params
      params.require(:url).permit(:original_url, :key, :expires_at)
    end

    def pagination_metadata(collection)
      {
        total_pages: collection.total_pages,
        current_page: collection.current_page,
        total_count: collection.total_count
      }
    end
  end
end
