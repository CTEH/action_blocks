FactoryBot.define do
  factory :order_detail do
    product { FactoryBot.create :product }
    order { FactoryBot.create :order }
  end
end
