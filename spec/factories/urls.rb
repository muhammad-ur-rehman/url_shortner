# spec/factories/urls.rb
FactoryBot.define do
  factory :url do
    original_url { "https://example.com/#{SecureRandom.hex(8)}" }
    key { SecureRandom.alphanumeric(6) }
    click_count { 0 }
    expires_at { 1.week.from_now }

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :high_click_count do
      click_count { rand(100..1000) }
    end
  end
end
