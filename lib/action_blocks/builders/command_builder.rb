module ActionBlocks

  class CommandBuilder < ActionBlocks::BlockType
    block_type :command
    
    references :context, handler: -> (command_builder, model_id) do
      command_builder.context_key = "model-#{model_id}"
    end
    builds :form, 'ActionBlocks::CommandFormBuilder'
    builds_with_block :results_in, 'ActionBlocks::CommandResultsBuilder'

    validates :results_in, presence: true

    def before_build(parent, id, *args)
      @id = id # aka name
    end
  end

  class CommandFormBuilder < ActionBlocks::BaseBuilder
    references :model

    def before_build(parent, *args)
      if parent.is_a?(ActionBlocks::CommandBuilder)
        @model_key = "model-#{parent.context.id}"
      end
    end
  end

  class CommandResultsBuilder < ActionBlocks::BaseBuilder
    sets :results_method

    def before_build(parent, id, &block)
      @id = id
      @results_method = block
    end
  end
end
