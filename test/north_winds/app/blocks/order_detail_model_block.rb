ActionBlocks.model :order_detail do
  active_model OrderDetail
  singular_name "Order Detail"
  plural_name "Order Details"
  name_field :product_name

  # Columns
  decimal :quantity
  decimal :unit_price
  decimal :discount
  string :status
  datetime :date_allocated
  datetime :created_at
  datetime :updated_at

  references :product do
    lookup :code
    lookup :name
    lookup :category
  end

  references :order

end
