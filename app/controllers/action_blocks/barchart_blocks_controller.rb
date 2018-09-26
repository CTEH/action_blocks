module ActionBlocks
  class BarchartBlocksController < ActionBlocks::BaseController
    before_action :authenticate_user!

    def analytics
      block = ActionBlocks.find(params[:block_key])
      user = nil
      if block.calculate == :count
        render plain: block.scope.call().group(block.group.column).count.to_json
      end
    end

  end
end
