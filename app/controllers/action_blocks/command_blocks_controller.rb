module ActionBlocks
  class CommandBlocksController < BaseController
      before_action :authenticate_user!

      # Called when command is clicked on client
      def record
        user = current_user
        command = ActionBlocks.find(params[:block_key]).implemented_by.new
        command.setup(user: current_user)

        # to_json comes from ActiveModel
        # additional logic might be needed for nesting depending on how we structure nesting in commands
        render json: command.to_json()
      end

      def create
        command = ActionBlocks.find(params[:block_key])
        cmd = command.implemented_by.new(
          #something
        )
        cmd.execute()
        # return result/validation errors/...?
      end

      def execute
        command = ActionBlocks.find(params[:block_key])
        params.permit!
        cmd = command.implemented_by.new(params)
        cmd.setup
        render json: cmd.execute
      end
  end
end
