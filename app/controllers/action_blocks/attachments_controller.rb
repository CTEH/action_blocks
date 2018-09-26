module ActionBlocks
  class AttachmentsController < ActionController::Base
      before_action :authenticate_user!

      def download
        model = ActionBlocks.find(params[:model_key])
        if model == nil
          raise RecordNotFound
        end
        id = params[:id]
        field = params[:field]
        record = model.active_model.find(id)
        attachment = record.send(field)
        begin
          send_data attachment.download
        rescue Module::DelegationError
          raise ActiveRecord::RecordNotFound
        end
      end

  end
end
