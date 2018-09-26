FactoryBot.define do
  factory :order do
    sequence(:num) { |n| 1000+n }
    customer { FactoryBot.create :customer }
    employee { FactoryBot.create :employee }
    region { FactoryBot.create :region }
    status { "active" }
  end
end
