class AddRegionToEmployees < ActiveRecord::Migration[5.2]
  def change
    add_reference :employees, :region, foreign_key: true
  end
end
