class Region < ApplicationRecord
    has_many :employees
    has_many :orders
end
