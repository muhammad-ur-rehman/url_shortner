require 'rails_helper'

RSpec.describe Url, type: :model do
  describe 'validations' do
    it 'is valid with a valid original_url and key' do
      url = build(:url)
      expect(url).to be_valid
    end

    it 'is invalid without an original_url' do
      url = build(:url, original_url: nil)
      expect(url).not_to be_valid
      expect(url.errors[:original_url]).to include("can't be blank")
    end

    it 'is invalid with a malformed original_url' do
      url = build(:url, original_url: 'invalid-url')
      expect(url).not_to be_valid
      expect(url.errors[:original_url]).to include('is invalid')
    end

    it 'is valid without a key as key is added using a callback' do
      url = build(:url, key: nil)
      expect(url).to be_valid
    end

    it 'is invalid with a duplicate key' do
      create(:url, key: 'duplicate-key')
      url = build(:url, key: 'duplicate-key')
      expect(url).not_to be_valid
      expect(url.errors[:key]).to include('has already been taken')
    end

    context 'when expires_at is present' do
      it 'is invalid if expires_at is in the past' do
        url = build(:url, expires_at: 1.day.ago)
        expect(url).not_to be_valid
        expect(url.errors[:expires_at]).to include('must be in the future')
      end

      it 'is invalid if expires_at is not a valid datetime' do
        url = build(:url)
        allow(url).to receive(:expires_at?).and_return(true) # Force the validation to run
        url.expires_at = '2026-01-1900:00:00' # Invalid format
        url.valid? # Trigger validations
        expect(url.errors[:expires_at]).to include("Must be a valid ISO 8601 datetime format (e.g., '2025-01-19 00:00:00')")
      end
    end
  end

  describe 'callbacks' do
    it 'generates a unique key before validation if key is blank' do
      url = build(:url, key: nil)
      expect(url).to be_valid
      expect(url.key).not_to be_nil
      expect(url.key.length).to be > 0
    end

    it 'raises an error if a custom key is already taken' do
      create(:url, key: 'custom-key')
      url = build(:url, key: 'custom-key')
      expect(url).not_to be_valid
      expect(url.errors[:key]).to include('has already been taken')
    end
  end

  describe 'instance methods' do
    describe '#expired?' do
      it 'returns true if the URL has expired' do
        url = build(:url, expires_at: 1.day.ago)
        expect(url.expired?).to be true
      end

      it 'returns false if the URL has not expired' do
        url = build(:url, expires_at: 1.day.from_now)
        expect(url.expired?).to be false
      end

      it 'returns false if expires_at is nil' do
        url = build(:url, expires_at: nil)
        expect(url.expired?).to be false
      end
    end
  end

  describe 'CRUD operations' do
    it 'creates a URL with valid attributes' do
      url = create(:url)
      expect(Url.count).to eq(1)
      expect(url.persisted?).to be true
    end

    it 'updates a URL with valid changes' do
      url = create(:url, original_url: 'https://old-url.com')
      url.update(original_url: 'https://new-url.com')
      expect(url.reload.original_url).to eq('https://new-url.com')
    end

    it 'does not update a URL with invalid changes' do
      url = create(:url)
      expect(url.update(original_url: nil)).to be false
      expect(url.errors[:original_url]).to include("can't be blank")
    end

    it 'deletes a URL' do
      url = create(:url)
      expect { url.destroy }.to change(Url, :count).by(-1)
    end
  end
end
