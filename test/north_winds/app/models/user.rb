class User < ApplicationRecord
    include Devise::JWT::RevocationStrategies::JTIMatcher
    devise :recoverable, :database_authenticatable, :jwt_authenticatable, jwt_revocation_strategy: self
    belongs_to :customer, optional: true
    belongs_to :employee, optional: true
end