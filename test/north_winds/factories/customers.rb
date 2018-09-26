FactoryBot.define do
  factory :customer do
    company { Faker::Company.name }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end
