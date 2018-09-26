require 'test_helper'

class TableBlocksControllerTest < ActionDispatch::IntegrationTest

  setup do
    ActionBlocks.config[:should_authorize] = false
    ActionBlocks.unload!
    ActionBlocks.model :order do
      active_model Order
      string :num
    end
    @user = FactoryBot.create :user
    sign_in(@user)
  end

  test "responds successfully to requests for records" do

    ActionBlocks.layout do
      workspace :construction do
        subspace :orders do
          dashboard :overview do
            table :list_all do
              model :order
              columns [:num]
              scope -> () { Order.all }
            end
          end
        end
      end
    end
    @table_block = ActionBlocks.find('table-construction_orders_overview_list_all')

    get "/action_blocks/table_blocks/#{@table_block.key}/records", headers: @auth_headers
    assert_response :success
  end
end
