require 'rails_helper'
require 'jwt'

RSpec.describe Jwt::Encode do
  describe '.encode' do
    let(:payload) { { user_id: 1 } }
    let!(:secret_key) { Rails.application.credentials.devise_jwt_secret_key }

    it 'returns a JWT token with the correct payload and expiration' do
      token = described_class.encode(payload)
      decoded_token = JWT.decode(token, secret_key, true, { algorithm: 'HS256' })

      expect(decoded_token).to be_a(Array)
      expect(decoded_token[0]['user_id']).to eq(payload[:user_id])
      expect(decoded_token[0]).to have_key('exp')
      expect(Time.at(decoded_token[0]['exp'])).to be_within(1.second).of(24.hours.from_now)
    end

    it 'raises an error if encoding fails' do
      allow(JWT).to receive(:encode).and_raise(StandardError, 'Encoding failed')

      expect { described_class.encode(payload) }.to raise_error(StandardError, 'Encoding failed')
    end
  end
end
