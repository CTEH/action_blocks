module ActionBlocks

  class CommandBuilder < ActionBlocks::BlockType
    block_type :command
    references :context, handler: -> (command_builder, model_id) do
      command_builder.context_key = "model-#{model_id}"
    end

    builds :form, 'ActionBlocks::CommandFormBuilder'

    def before_build(parent, id, *args)
      @id = id # aka name
    end
  end

  class CommandFormBuilder < ActionBlocks::BaseBuilder
    references :model

    def before_build(parent, *args)
      if parent.is_a?(ActionBlocks::CommandBuilder)
        @model = parent.context
      end
    end
  end
end
