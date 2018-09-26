class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :product_code
      t.string :product_name
      t.string :description
      t.decimal :list_price, precision: 17, scale: 2
      t.integer :target_level
      t.integer :reorder_level
      t.integer :minimum_reorder_quantity
      t.string :quantity_per_unit
      t.boolean :discounted
      t.string :category

      t.timestamps
    end
  end
end
