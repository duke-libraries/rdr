FactoryBot.define do
  factory :user do
    sequence(:uid) { |n| "user#{n}@example.com" }
    sequence(:email) { |n| "first.last#{n}@example.com" }
    password { 'secret' }
  end
end
