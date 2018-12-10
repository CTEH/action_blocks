class CreateProductVariations < ActiveRecord::Migration[5.2]
  def change
    create_table :product_variations do |t|
      t.references :product, foreign_key: true
      t.string :description
      t.string :code
      t.string :color
      t.string :size

      t.timestamps
    end
  end
end
