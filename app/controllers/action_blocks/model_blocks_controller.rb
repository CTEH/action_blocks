module ActionBlocks

  class ModelBlocksController < ActionBlocks::BaseController
    before_action :authenticate_user!

    def name
      model_block = ActionBlocks.find(params[:block_key])
      record_id = Integer(params[:record_id])
      render json: model_block.name_to_json(record_id: record_id, user: current_user)
    end
  end

end
