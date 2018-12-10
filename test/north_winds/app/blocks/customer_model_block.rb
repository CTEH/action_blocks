ActionBlocks.model :customer do
  active_model Customer
  singular_name "Customer"
  plural_name "Customers"
  name_field :last_name

  # Columns
  string :last_name
  string :first_name
  string :email
  string :company
  string :phone
  text :address1
  text :address2
  string :city
  string :state
  string :postal_code
  string :country
  datetime :created_at
  datetime :updated_at
  string :status

end
