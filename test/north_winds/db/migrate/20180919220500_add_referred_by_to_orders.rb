class AddReferredByToOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :orders, :referred_by, foreign_key: { to_table: :customers }
  end
end
