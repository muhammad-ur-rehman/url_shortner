require 'rails_helper'

RSpec.describe Api::RedirectController, type: :controller do
  let(:url) { create(:url, original_url: 'https://example.com') }
  let(:expired_url) { create(:url, original_url: 'https://expired.com') }

  describe 'GET #show' do
    context 'when the URL is not expired' do
      before do
        UrlCacheService.new(nil).redis.flushall
      end

      it 'redirects to the original URL' do
        get :show, params: { short_url: url.key }

        expect(response).to redirect_to(url.original_url)
        expect(response).to have_http_status(:found)
      end

      it 'increments the click count in cache' do
        expect_any_instance_of(UrlCacheService).to receive(:increment_click_count)
        get :show, params: { short_url: url.key }
      end
    end

    context 'when the URL is expired' do
      before do
        expired_url.update_column(:expires_at, 1.day.ago)
        expired_url.reload
        UrlCacheService.new(nil).redis.flushall
      end
      it 'returns a gone error' do
        get :show, params: { short_url: expired_url.key }

        expect(response).to have_http_status(:gone)
        expect(JSON.parse(response.body)['error']).to eq('URL has expired')
      end
    end

    context 'when the URL is not found' do
      it 'returns a not found error if URL is not in cache or DB' do
        allow_any_instance_of(UrlCacheService).to receive(:fetch_from_cache_using_key).and_return(nil)
        allow(Url).to receive(:find_by).and_return(nil)

        get :show, params: { short_url: 'non_existent_key' }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('URL not found')
      end
    end
  end
end
