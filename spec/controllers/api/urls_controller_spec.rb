require 'rails_helper'

RSpec.describe Api::UrlsController, type: :controller do
  let(:valid_attributes) do
    {
      original_url: "https://example.com/#{SecureRandom.hex(8)}",
      key: SecureRandom.alphanumeric(6),
      expires_at: 1.week.from_now
    }
  end

  let(:invalid_attributes) do
    {
      original_url: 'invalid-url',
      key: nil,
      expires_at: 1.day.ago
    }
  end

  let(:url) { create(:url) }
  let(:cache_service) { instance_double(UrlCacheService) }

  describe 'GET #index' do
    before do
      create_list(:url, 15) # Seed 15 records for pagination testing
    end

    it 'returns paginated URLs with metadata' do
      get :index, params: { page: 1, per_page: 10 }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['data'].size).to eq(10)
      expect(body['metadata']).to include('total_pages', 'current_page', 'total_count')
    end

    it 'returns the correct number of URLs per page' do
      get :index, params: { page: 2, per_page: 5 }
      body = JSON.parse(response.body)
      expect(body['data'].size).to eq(5)
      expect(body['metadata']['current_page']).to eq(2)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new URL and caches it' do
        allow(UrlCacheService).to receive(:new).and_return(cache_service)
        expect(cache_service).to receive(:save_to_cache)

        expect do
          post :create, params: { url: valid_attributes }
        end.to change(Url, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        post :create, params: { url: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body).to include('expires_at must be in the future')
      end

      it 'returns error for invalid expires_at format' do
        post :create, params: { url: valid_attributes.merge(expires_at: '2026-01-1900:00:00') }
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body).to include("Expires at must be a valid ISO 8601 datetime format (e.g., '2025-01-19 00:00:00')")
      end
    end
  end

  describe 'GET #show' do
    context 'when URL exists in cache' do
      it 'returns the cached URL' do
        allow(UrlCacheService).to receive(:new).and_return(cache_service)
        allow(cache_service).to receive(:fetch_from_cache_using_id).and_return(url.attributes)

        get :show, params: { id: url.id }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['id']).to eq(url.id)
      end
    end

    context 'when URL does not exist' do
      it 'returns a 404 error' do
        get :show, params: { id: 'nonexistent_id' }
        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body['error']).to eq('URL not found')
      end
    end
  end

  describe 'Caching Behavior' do
    before do
      UrlCacheService.new(url).save_to_cache
    end

    it 'fetches the URL from cache if available' do
      expect(Url).not_to receive(:find)
      expect(UrlCacheService.new(url).fetch_from_cache_using_id(url.id).keys).to eq(url.attributes.keys.map(&:to_sym))
      expect(UrlCacheService.new(url).fetch_from_cache_using_id(url.id)[:id]).to eq(url.id)

      get :show, params: { id: url.id }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Error Handling' do
    it 'handles internal server errors gracefully' do
      allow_any_instance_of(Api::UrlsController).to receive(:index).and_raise(StandardError, 'Something went wrong')

      get :index

      expect(response).to have_http_status(:internal_server_error)
      body = JSON.parse(response.body)
      expect(body['errors']).to include('Something went wrong')
    end
  end
end
