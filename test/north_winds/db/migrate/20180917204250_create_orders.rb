class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.references :employee, foreign_key: true
      t.references :customer, foreign_key: true
      t.datetime :order_date
      t.datetime :shipped_date
      t.string :ship_name
      t.text :ship_address1
      t.text :ship_address2
      t.string :ship_city
      t.string :ship_state
      t.string :ship_postal_code
      t.string :ship_country
      t.decimal :shipping_fee, precision: 17, scale: 2
      t.string :payment_type
      t.datetime :paid_date
      t.string :order_status

      t.timestamps
    end
  end
end
