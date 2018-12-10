ActionBlocks.model :order do
  active_model Order
  singular_name "Order"
  plural_name "Orders"
  name_field :num

  # Columns
  datetime :order_date
  datetime :shipped_date
  string :ship_name
  text :ship_address1
  text :ship_address2
  string :ship_city
  string :ship_state
  string :ship_postal_code
  string :ship_country
  decimal :shipping_fee
  string :payment_type
  datetime :paid_date
  string :status
  datetime :created_at
  datetime :updated_at
  string :num

  selection :order_details

  references :customer do
    lookup :first_name
    lookup :last_name
    lookup :company
  end

  references :employee do
    lookup :first_name
    lookup :last_name
    lookup :department
  end

end
