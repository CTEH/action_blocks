class CreateOrderDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :order_details do |t|
      t.references :order, foreign_key: true
      t.references :product, foreign_key: true
      t.decimal :quantity, precision: 17, scale: 2
      t.decimal :unit_price, precision: 17, scale: 2
      t.decimal :discount, precision: 17, scale: 2
      t.string :order_detail_status
      t.datetime :date_allocated

      t.timestamps
    end
  end
end
