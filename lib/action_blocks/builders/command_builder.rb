module ActionBlocks

  class CommandBuilder < ActionBlocks::BlockType
    block_type :command
    
    references :context, handler: -> (command_builder, model_id) do
      command_builder.context_key = "model-#{model_id}"
    end
    builds :form, 'ActionBlocks::CommandFormBuilder'
    # builds_with_block :results_in, 'ActionBlocks::CommandResultsBuilder'

    sets :implemented_by

    validates :implemented_by, presence: true

    def before_build(parent, id, *args)
      @id = id # aka name
    end

    def hashify(_user)
      {
        context: @context_key,
        interactive: !@form.nil?
      }
    end
  end

  class CommandFormBuilder < ActionBlocks::BaseBuilder
    references :model

    builds_many :lookups, :lookup, 'ActionBlocks::CommandFormLookupBuilder'

    builds_many :references, :reference, 'ActionBlocks::CommandFormReferenceBuilder'

    builds_many :details, :details, 'ActionBlocks::CommandFormDetailsBuilder'

    builds_many :calculations, :calculate, 'ActionBlocks::CommandFormCalculationBuilder'

    def before_build(parent, *_args)
      @model_key = "model-#{parent.context.id}" if parent.is_a?(ActionBlocks::CommandBuilder)
    end

    def hashify(_user)
      {
        model: @model_key,
        lookups: @lookups.map(&:hashify),
        references: @references.map(&:hashify),
        details: @details.map(&:hashify),
        calculations: @calculations.map(&:hashify)
      }
    end
  end

  class CommandFormLookupBuilder < ActionBlocks::BaseBuilder
    sets :reference
    sets :field

    def before_build(parent, *args)
      @reference = args[0]
      @field = args[1] unless args[1].nil?

      @command = parent
    end

    def hashify(_user)
      reference_builder = @command.references.find { |r| r.key == @reference }
      reference_value = reference_builder.reference_value
      {
        field: @field,
        value: reference_value[@field]
      }
    end
  end

  class CommandFormReferenceBuilder < ActionBlocks::BaseBuilder
    builds :behavior, 'ActionBlocks::CommandFormBehaviorBuilder'
    sets_many :params, :param
    sets :display # TODO: needs default value
    sets :value
    sets :key

    def before_build(parent, *args)
      @key = args[0]
      @context = parent.context
    end

    def reference_value()
      # return @value(@context) # syntax? value is a block, need to call it
    end

    def hashify(_user)
      {
        # TODO
      }
    end
  end

  class CommandFormDetailsBuilder < ActionBlocks::BaseBuilder
    builds :behavior, 'ActionBlocks::CommandFormBehaviorBuilder'
    builds_many :references, :reference, 'ActionBlocks::CommandFormReferenceBuilder'
    builds_many :calculations, :calculate, 'ActionBlocks::CommandFormCalculationBuilder'
    builds_many :lookups, :lookup, 'ActionBlocks::CommandFormLookupBuilder'

    builds_many :fields, :decimal, 'ActionBlocks::CommandFormDetailsDecimalFieldBuilder'
    builds_many :fields, :string, 'ActionBlocks::CommandFormDetailsStringFieldBuilder'

    def hashify(_user)
      {
        # TODO
      }
    end
  end

  class CommandFormFieldBuilder < ActionBlocks::BaseBuilder
    attr_accessor :field_type
    sets :field

    def hashify(_user)
      {
        type: @field_type,
        field: @field
      }
    end
  end

  class CommandFormDetailsDecimalFieldBuilder < CommandFormFieldBuilder
    def before_build(parent, *args)
      super(parent, *args)
      @field_type = :decimal
    end
  end

  class CommandFormDetailsStringFieldBuilder < CommandFormFieldBuilder
    def before_build(parent, *args)
      super(parent, *args)
      @field_type = :string
    end
  end

  # TODO: Add other field types

  class CommandFormCalculationBuilder < ActionBlocks::BaseBuilder
    sets :field
    sets :formula

    def before_build(_parent, *args)
      @field = args[0] unless args[0].nil?
      @formula = args[1] unless args[1].nil?
    end

    def hashify(_user)
      {
        # TODO
      }
    end
  end

  class CommandFormBehaviorBuilder < ActionBlocks::BaseBuilder
    sets :default
    sets :editable

    def before_build(_parent, *args)
      @default = args[0] unless args[0].nil?
    end

    def hashify(_user)
      {
        # TODO
      }
    end
  end

  # class CommandResultsBuilder < ActionBlocks::BaseBuilder
  #   sets :results_method

  #   def before_build(parent, id, &block)
  #     @id = id
  #     @results_method = block
  #   end
  # end
end
