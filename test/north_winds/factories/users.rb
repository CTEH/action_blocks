FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@cteh.com" }
    password {"secretpassword"}
  end
end
