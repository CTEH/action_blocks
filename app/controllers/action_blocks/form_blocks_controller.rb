module ActionBlocks

  class FormBlocksController < ActionBlocks::BaseController
      before_action :authenticate_user!

      def record
        form = ActionBlocks.find(params[:block_key])
        record_id = Integer(params[:record_id])
        render json: form.record_to_json(user: current_user, record_id: record_id)
      end

  end
end
