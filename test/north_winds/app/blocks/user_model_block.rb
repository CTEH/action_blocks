ActionBlocks.model :user do
  active_model User
  singular_name "User"
  plural_name "Users"
  name_field :email

  # Columns
  string :email
  string :encrypted_password
  string :reset_password_token
  datetime :reset_password_sent_at
  datetime :remember_created_at
  datetime :current_sign_in_at
  datetime :last_sign_in_at
  string :current_sign_in_ip
  string :last_sign_in_ip
  integer :failed_attempts
  string :unlock_token
  datetime :locked_at
  datetime :created_at
  datetime :updated_at
  string :jti
  string :role
end

