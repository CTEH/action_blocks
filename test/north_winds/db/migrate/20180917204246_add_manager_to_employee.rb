class AddManagerToEmployee < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :employees, :employees, column: :manager_id
  end
end
