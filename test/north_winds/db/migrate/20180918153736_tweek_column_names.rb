class TweekColumnNames < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :num, :string
    rename_column :orders, :order_status, :status
    rename_column :order_details, :order_detail_status, :status
    rename_column :products, :product_code, :code
    rename_column :products, :product_name, :name
  end
end
