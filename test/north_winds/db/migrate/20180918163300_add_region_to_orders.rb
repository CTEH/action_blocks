class AddRegionToOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :orders, :region, foreign_key: true
  end
end
