module ActionBlocks

  class BaseController < ApplicationController
    # Disable need for authenticity token as we
    # we are integrating with clients not rendered by rails

    # JRH - https://labs.chiedo.com/blog/authenticating-your-reactjs-app-with-devise-no-extra-gems-needed/

    before_action :validate_action_block
    def validate_action_block
      if Rails.env.development? || Rails.env.test?
        if ActionBlocks.invalid?
          Rails.logger.error "ActionBlock application invalid"
          Rails.logger.error ActionBlocks.errors
          raise "ActionBlock application invalid #{ActionBlocks.errors}"
        end
      end
    end

  end

end
