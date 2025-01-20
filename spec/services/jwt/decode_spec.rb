require 'rails_helper'
require 'jwt'

RSpec.describe Jwt::Decode do
  describe '.decode' do
    let(:payload) { { user_id: 1 } }
    let(:secret_key) { Rails.application.credentials.devise_jwt_secret_key }
    let(:valid_token) { JWT.encode(payload, secret_key, 'HS256') }
    let(:invalid_token) { 'invalid.token.value' }

    context 'when the token is valid' do
      it 'returns the decoded payload' do
        decoded_payload = described_class.decode(valid_token)

        expect(decoded_payload).to be_a(Hash)
        expect(decoded_payload['user_id']).to eq(payload[:user_id])
      end
    end

    context 'when the token is invalid' do
      it 'returns nil' do
        decoded_payload = described_class.decode(invalid_token)

        expect(decoded_payload).to be_nil
      end
    end

    context 'when the token is expired' do
      let(:expired_token) do
        expired_payload = payload.merge({ exp: 1.minute.ago.to_i })
        JWT.encode(expired_payload, secret_key, 'HS256')
      end

      it 'returns nil' do
        decoded_payload = described_class.decode(expired_token)

        expect(decoded_payload).to be_nil
      end
    end

    context 'when an error occurs during decoding' do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::DecodeError, 'Decode error')
      end

      it 'returns nil' do
        decoded_payload = described_class.decode(valid_token)

        expect(decoded_payload).to be_nil
      end
    end
  end
end
