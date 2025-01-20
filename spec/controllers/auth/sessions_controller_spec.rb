require 'rails_helper'

RSpec.describe Auth::SessionsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:valid_user_attributes) do
    {
      email: 'test@example.com',
      password: 'password',
      password_confirmation: 'password'
    }
  end

  let(:invalid_user_attributes) do
    {
      email: 'invalid@example',
      password: 'short',
      password_confirmation: 'mismatch'
    }
  end

  let(:existing_user) { User.create!(email: 'user@example.com', password: 'password') }

  describe 'POST #signup' do
    context 'with valid attributes' do
      it 'creates a new user and returns a JWT' do
        post :signup, params: { user: valid_user_attributes }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key('jwt')
        expect(User.find_by(email: valid_user_attributes[:email])).not_to be_nil
      end
    end

    context 'with invalid attributes' do
      it 'does not create a user and returns errors' do
        post :signup, params: { user: invalid_user_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
        expect(User.find_by(email: invalid_user_attributes[:email])).to be_nil
      end
    end
  end

  describe 'POST #create (login)' do
    context 'with valid credentials' do
      it 'returns a JWT for the user' do
        post :create, params: { email: existing_user.email, password: 'password' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key('jwt')
      end
    end

    context 'with invalid credentials' do
      it 'returns an unauthorized error' do
        post :create, params: { email: existing_user.email, password: 'wrongpassword' }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to have_key('error')
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end
    end

    context 'with non-existent user' do
      it 'returns an unauthorized error' do
        post :create, params: { email: 'nonexistent@example.com', password: 'password' }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to have_key('error')
        expect(JSON.parse(response.body)['error']).to eq('Invalid email or password')
      end
    end
  end
end
