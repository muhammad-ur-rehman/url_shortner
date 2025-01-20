require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let(:valid_attributes) { { email: 'test@example.com', password: 'password123' } }
    let(:user) { User.new(valid_attributes) }

    context 'when email is valid' do
      it 'is valid with a proper email format' do
        expect(user).to be_valid
      end

      it 'is invalid without an email' do
        user.email = nil
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end

      it 'is invalid with a duplicate email' do
        User.create!(valid_attributes)
        duplicate_user = User.new(valid_attributes)
        expect(duplicate_user).not_to be_valid
        expect(duplicate_user.errors[:email]).to include('has already been taken')
      end

      it 'is invalid with an improperly formatted email' do
        user.email = 'invalid_email'
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include('is invalid')
      end
    end

    context 'when password is valid' do
      it 'is valid with a minimum length of 6 characters' do
        user.password = '123456'
        expect(user).to be_valid
      end

      it 'is invalid without a password' do
        user.password = nil
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end

      it 'is invalid with a password less than 6 characters' do
        user.password = '12345'
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
      end
    end
  end

  describe 'devise modules' do
    it 'includes database_authenticatable' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes jwt_authenticatable' do
      expect(User.devise_modules).to include(:jwt_authenticatable)
    end
  end
end
