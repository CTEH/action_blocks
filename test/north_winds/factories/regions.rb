FactoryBot.define do
    factory :region do
        title { Faker::Address.country }
    end
end
