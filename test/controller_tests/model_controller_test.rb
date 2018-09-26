require 'test_helper'

class ModelControllerTest < ActionDispatch::IntegrationTest

  setup do
    ActionBlocks.config[:should_authorize] = false
    ActionBlocks.unload!
    ActionBlocks.model :order do
      active_model Order
      string :num
      name_field :num
    end
    @user = FactoryBot.create :user
    sign_in(@user)
  end

  test "responds successfully to requests for name_field" do
    wo = FactoryBot.create :order
    @model = ActionBlocks.find('model-order')

    get "/action_blocks/model_blocks/#{@model.key}/#{wo.id}/name", headers: @auth_headers
    assert_response :success
  end
end
