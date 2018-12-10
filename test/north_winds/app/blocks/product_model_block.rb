ActionBlocks.model :product do
  active_model Product
  singular_name "Product"
  plural_name "Products"
  name_field :name

  # Columns
  string :code
  string :name
  string :description
  decimal :list_price
  integer :target_level
  integer :reorder_level
  integer :minimum_reorder_quantity
  string :quantity_per_unit
  # boolean :discounted
  string :category
  datetime :created_at
  datetime :updated_at

end
