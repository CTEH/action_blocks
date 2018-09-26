FactoryBot.define do
    factory :product do
      sequence(:code) { |n| 1000+n }
      name { '#{Faker::Appliance.brand} #{Faker::Appliance.equipment}' } 
      list_price { Integer(rand*10000)/100.00 + 400.00 }
    end
  end
  