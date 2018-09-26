class CreateEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :employees do |t|
      t.string :last_name
      t.string :first_name
      t.string :email
      t.string :avatar
      t.string :job_title
      t.string :department
      t.string :phone
      t.text :address1
      t.text :address2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country
      t.references :manager, index: true
      t.timestamps
    end
  end
end
