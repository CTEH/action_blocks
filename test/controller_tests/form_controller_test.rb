require 'test_helper'

class FormBlocksControllerTest < ActionDispatch::IntegrationTest

  setup do
    ActionBlocks.config[:should_authorize] = false
    ActionBlocks.unload!
    @user = FactoryBot.create :user
    sign_in(@user)
  end

  test "responds successfully to requests for record" do
    wo = FactoryBot.create :order

    ActionBlocks.model :order do
      active_model Order
      string :num
    end
    ActionBlocks.form :construction_order_form do
      model :order
      section :main do
        field :num
      end
    end

    form = ActionBlocks.find('form-construction_order_form')
    get "/action_blocks/form_blocks/#{form.key}/#{wo.id}/record", headers: @auth_headers
    assert_response :success

  end
end
