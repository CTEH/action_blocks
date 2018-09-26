class Order < ApplicationRecord
  belongs_to :region
  belongs_to :employee
  belongs_to :customer
  belongs_to :referred_by, class_name: 'Customer', optional: true
  has_many :order_details
end
