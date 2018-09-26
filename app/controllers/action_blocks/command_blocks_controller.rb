module ActionBlocks
  class CommandBlocksController < BaseController
      before_action :authenticate_user!

  end
end
