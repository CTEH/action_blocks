ActionBlocks.layout do
    workspace :operations do
      subspace :orders do
        dashboard :list_all do
          table :list_all do
            model :order
            columns [:employee, :customer, :order_date, :status, :updated_at]
          end
        end
      end
  
      subspace :orders, :order do
        dashboard :overview do
        #   mount_form "operations_order_form"
        end
        dashboard :order_details do
          table :order_details do
            model :order_detail
            selection :order, :order_details
            columns [:product_code, :product_name, :quantity, :unit_price, :discount]
          end
        end
      end  
    end

    workspace :management do
      subspace :users do
        dashboard :list do
          table :all_users do
            model :user
            columns [:email]
          end
        end
      end
  
      subspace :users, :user do
        dashboard :profile do
        #   mount_form "management_user_form"
        end
      end
    end
  end
  