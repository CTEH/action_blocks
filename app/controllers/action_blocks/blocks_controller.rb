module ActionBlocks
  class BlocksController < BaseController
    before_action :authenticate_user!
    skip_before_action :validate_action_block

    def index
      user = nil
      if ActionBlocks.invalid?
        render json: {errors: ActionBlocks.errors}.to_json, content_type: 'application/json'
      else
        render json: ActionBlocks.hashify(user).to_json, content_type: 'application/json'
      end
    end

  end
end
