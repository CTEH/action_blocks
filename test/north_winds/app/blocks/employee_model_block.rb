ActionBlocks.model :employee do
  active_model Employee
  singular_name "Employee"
  plural_name "Employees"
  name_field :last_name

  # Columns
  string :last_name
  string :first_name
  string :email
  string :avatar
  string :job_title
  string :department
  string :phone
  text :address1
  text :address2
  string :city
  string :state
  string :postal_code
  string :country
  datetime :created_at
  datetime :updated_at

end
