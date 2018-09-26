module ActionBlocks
  class TableBlocksController < ActionBlocks::BaseController
    before_action :authenticate_user!

    def records
      params.permit([:block_key, :subspace_model_id, :dashboard_model_id])
      user = current_user
      table = ActionBlocks.find(params[:block_key])
      render json: table.to_json(user: current_user, params: params)
    end

  end
end
