class AddStatusToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :status, :string
  end
end
