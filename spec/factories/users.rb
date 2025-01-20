FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" } # Ensures unique email addresses
    password { 'password123' }                     # Default password
    password_confirmation { 'password123' }        # Password confirmation for Devise
  end
end
