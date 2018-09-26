module ActionBlocks
  class WorkspaceBlocksController < ActionBlocks::BaseController
      before_action :authenticate_user!

  end
end
