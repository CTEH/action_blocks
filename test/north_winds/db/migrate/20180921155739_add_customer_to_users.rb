class AddCustomerToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :customer, foreign_key: true
  end
end
