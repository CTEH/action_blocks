module ActionBlocks

  class CommandBuilder < ActionBlocks::BlockType
    block_type :command
    references :context, handler: -> (command_builder, model_id) do
      command_builder.context_key = "model-#{model_id}"
      # command_builder.context_id = model_id
    end

    def before_build(parent, id, *args)
      @id = id # aka name
    end
  end
end
