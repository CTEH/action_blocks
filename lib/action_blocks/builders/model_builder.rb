module ActionBlocks
  class ModelBuilder < ActionBlocks::BlockType
    block_type :model
    sets :active_model
    sets :singular_name
    sets :plural_name
    references :name_field, :field, -> (s, obj) {"field-#{obj.id}-#{s}"}

    builds_many :fields, :identity, 'ActionBlocks::IdentityFieldBuilder'
    builds_many :fields, :string, 'ActionBlocks::StringFieldBuilder'
    builds_many :fields, :text, 'ActionBlocks::TextFieldBuilder'
    builds_many :fields, :datetime, 'ActionBlocks::DatetimeFieldBuilder'
    builds_many :fields, :date, 'ActionBlocks::DateFieldBuilder'
    builds_many :fields, :integer, 'ActionBlocks::IntegerFieldBuilder'
    builds_many :fields, :attachment, 'ActionBlocks::AttachmentBuilder'

    builds_many :fields, :references, 'ActionBlocks::ReferenceFieldBuilder'
    builds_many :selections, :selection, 'ActionBlocks::SelectionBuilder'

    validate :active_model_is_an_active_record_class
    def active_model_is_an_active_record_class
      if @active_model.class != Class
        errors.add(:active_model, "Must be an ActiveRecord Class")
      else
        if !@active_model.ancestors.include? ActiveRecord::Base
          errors.add(:active_model, "Must be an ActiveRecord Class")
        end
      end
    end

    def after_build(parent, *args)
      # Every model has an identity field
      if !@fields.map(&:id).include?(:id)
        @dsl_delegate.identity
      end
    end

    def select_requirements(fields = nil)
      sel_reqs = @fields.map(&:select_requirements)
      sel_reqs = sel_reqs.select { |r| fields.include? r[:field_name] } unless fields.nil?

      return sel_reqs
    end

    def name_to_json(record_id:, user:)
      select_reqs = [name_field.select_requirements]
      filter_reqs = [:eq, :id, record_id]
      engine = DataEngine.new(active_model, select_reqs: select_reqs, filter_reqs: filter_reqs)
      engine.first_to_json
    end

    def selection_filter_reqs(record_id:, user:)
      [
          {
            base_path: [active_model, :id],
            predicate: :eq,
            related_path: [record_id]
          }
      ]
    end

    def filter_reqs(record_id:, user:)
      [:eq, :id, record_id]
    end

    def hashify(user)
      {
        key: key,
        type: type,
        name_field: name_field.try(:id),
        singular_name: singular_name,
        plural_name: plural_name
      }
    end

  end

  class ActionBlocks::SelectionBuilder < ActionBlocks::BlockType
    attr_accessor :base_model, :related_model_id, :match_conditions_source
    references :related_model
    block_type :selection
    builds_many :match_conditions, :match_condition, 'ActionBlocks::MatchConditionBuilder'
    builds_many :summaries, :summary, 'ActionBlocks::SummaryFieldBuilder'

    validate :match_conditions_exist
    def match_conditions_exist
      if @match_conditions.length == 0
        errors.add(:match_conditions, "No match conditions on selection #{key}")
      end
    end

    validate :match_conditions_come_from_relation_if_relation_exists
    def match_conditions_come_from_relation_if_relation_exists
      if @match_conditions_source == 'user defined'
        # puts @base_model.active_model.reflections.keys.inspect
        relation = @base_model.active_model.reflections[@id.to_s]

        if relation && relation.collection?
          errors.add(:match_conditions, "Selections name matches name of has_many, but defines match_conditions anyway")
        end
      end
    end

    def key
      "selection-#{@base_model.id}-#{@id}"
    end

    def before_build(parent, id, *args)
      @base_model = parent
      @id = id # aka name
      if args[0]
        @related_model_id = args[0].to_sym
      else
        @related_model_id = @id.to_s.singularize.to_sym
      end
      @related_model_key = "model-#{@related_model_id}"
    end

    def after_build(parent, *args)
      if @match_conditions.length == 0
        build_match_conditions_by_reflecting
      else
        @match_conditions_source = "user defined"
      end
    end

    def build_match_conditions_by_reflecting
      relation = @base_model.active_model.reflections[@id.to_s]
      if relation && relation.collection?
        @match_conditions_source = "relation"
        if relation.class == ActiveRecord::Reflection::HasManyReflection
          @dsl_delegate.match_condition relation.join_keys.foreign_key.to_sym, :eq, relation.join_keys.key.to_sym
        else
          raise "Relation #{relation.class} not supported"
        end
      end
    end

    def match_reqs(*p)
      user = p.first
      match_conditions.map(&:match_reqs)
    end

    def record_filter_reqs(record:, user:)
      if record.class != @base_model.active_model
        raise "Selection issue."
      end
      @base_model.selection_filter_reqs(record_id: record.id, user: user)
    end

    def hashify(user)
      {
        key: key,
        type: type
      }
    end

  end

  # Base - Refers to the selecting model and fields on selecting model
  # Related - Refers to the selected model and fields on selected model
  # e.g. When a Work Order selects Items
  #      Item is Related Model
  #      WorkOrder is Base Model
  #
  # When building a match condition, its defined in the Base Models
  # builder.
  # e.g. When a Work Order selects Items
  #      This selection is declared in the Work Order Model
  #
  # When using a selection to select related items, such as a table
  # the Base Model (Work Order) feels a bit misnamed from this context
  # as Items are being selected and form the foundation of the query.

  class ActionBlocks::MatchConditionBuilder < ActionBlocks::BaseBuilder
    attr_accessor :related_field_id, :base_field_id, :parent_model, :related_model
    references :base_field
    references :related_field
    sets :predicate

    def before_build(parent, base_field, predicate, related_field)
      if base_field.is_a? Symbol
        @base_model = parent.base_model
        @base_field_id = base_field
        @base_field_key = "field-#{parent.base_model.id}-#{@base_field_id}"
      else
        @base_value = base_field
      end

      @related_model = parent.related_model
      @related_field_id = related_field
      @related_field_key = "field-#{parent.related_model_id}-#{@related_field_id}"

      @predicate = predicate
    end

    def base_match_reqs
      if @base_value
        {
        path: [@base_value]
        }
      else
        field_reqs = base_field.match_requirements(@base_model.active_model)
        {
          path: field_reqs[:path]
        }
      end
    end

    def related_match_reqs
      field_reqs = related_field.match_requirements()
      {
        path: field_reqs[:path]
      }
    end

    def match_reqs
      {
        base_path: base_match_reqs[:path],
        predicate: @predicate,
        related_path: related_match_reqs[:path]
      }
    end
  end


  class ActionBlocks::FieldBlock < ActionBlocks::BlockType
    attr_accessor :parent_model, :field_type
    block_type :field
    sets :name
    sets :label

    def key
      "field-#{@parent_model.id}-#{@id}"
    end

    def select_requirements(select_as_prefix = nil)
      {
        field_name: [select_as_prefix,@id].compact.join('_').to_sym,
        path: [@id]
      }
    end

    def match_requirements(select_as_prefix = nil)
      {
        path: [select_as_prefix, @id].compact
      }
    end

    def before_build(parent, *args)
      @parent_model = parent
    end
  end

  class SummaryFieldBuilder < ActionBlocks::FieldBlock
    include ActionBlocks::SummaryFieldAggregationFunctions
    attr_accessor :parent_reference, :aggregation, :base_model, :related_model_id, :related_model
    references :target_field
    sets :aggregate
    sets :aggregate_parameters
    builds_many :filters, :filter, 'ActionBlocks::MatchConditionBuilder'

    # validates :aggregate, inclusion: { in: %i[sum count avg min max string_agg] }

    def before_build(parent, *args)
      @base_model = parent.base_model # required lookup for match conditions
      @related_model = parent.related_model # required lookup for match conditions
      @related_model_id = parent.related_model_id # required lookup for match conditions

      @field_type = 'summary'
      @field_name = args[0]
      @parent_reference = parent
      @parent_model = @parent_reference.base_model

      @aggregate = args[1]
    end

    def after_build(parent, *args)
      @parent_model.fields.append(self)
    end

    # summary_reqs = [{
    #   type: :summary
    #   root_klass: Rate,
    #   select_req: { field_name: :count_of_rates, path: [:id], aggregate: ->(*args) { count(*args) } },
    #   match_reqs: [{
    #     base_path: [WorkOrder, :rate_sheet_id], # work_order
    #     predicate: :eq,
    #     related_path: [:rate_sheet_id]   # rate
    #   }]
    # }]
    def select_requirements(select_as_prefix = nil)
      path_and_function = instance_exec(&@aggregate)
      path = path_and_function[:path]
      function = path_and_function[:function]

      {
        type: :summary,
        root_klass: parent_reference.related_model.active_model,
        select_req: {
          field_name: @field_name,
          path: path,
          function: function
        },
        match_reqs: parent_reference.match_reqs,
        filter_reqs: filters.map(&:match_reqs)
      }
    end

    def hashify(user)
      {
        type: :summary,
        id: @id
      }
    end
  end

  class IdentityFieldBuilder < ActionBlocks::FieldBlock
    def before_build(parent, *args)
      @field_type = 'identity'
      @id = :id
      super(parent, :id)
    end

    def select_requirements(select_as_prefix = nil)
      {
        field_name: [select_as_prefix,@id].compact.join('_').to_sym,
        path: [@id]
      }
    end

    def match_requirements(select_as_prefix = nil)
      {
        path: [select_as_prefix, @id].compact
      }
    end

    def hashify(user)
      {
        type: :identity,
        id: @id,
        key: @key
      }
    end
  end


  class ReferenceFieldBuilder < ActionBlocks::FieldBlock
    attr_accessor :association_name
    references :model
    builds_many :lookups, :lookup, 'ActionBlocks::LookupFieldBuilder'

    def before_build(parent, *args)
      super(parent, *args)
      @association_name = args[0]
      @field_type = 'reference'
      @model_key = "model-#{args[1] || args[0]}"
      add_foreign_key_as_integer(parent)
    end

    def add_foreign_key_as_integer(parent)
      if relation
        parent.dsl_delegate.integer(relation.join_foreign_key.to_sym)
      end
    end

    validate :validate_association_name

    def relation
      if @parent_model.active_model
        @parent_model.active_model.reflections[@association_name.to_s]
      end
    end

    def validate_association_name
      # puts @parent_model.active_model.reflections.keys.inspect
      # puts @association_name.to_s
      unless relation
        errors.add(:association_name, "Association #{@association_name.to_s} is not a valid relationship for model #{@parent_model.active_model.to_s}.  Valid relations include: #{@parent_model.active_model.reflections.keys.inspect}")
      end

      unless relation && relation.belongs_to?
        errors.add(:association_name, "Association #{@association_name.to_s} is not a valid belongs_to relationship")
      end
    end

    def select_requirements(select_as_prefix = nil)
      target_data_reqs = model.name_field.select_requirements([select_as_prefix, association_name].compact.join('_'))
        {
          field_name: association_name,
          path: [association_name, target_data_reqs[:path]].flatten,
        }
    end

    def match_requirements(select_as_prefix = nil)
        {
          path: [select_as_prefix, [association_name, relation.join_primary_key].join('_').to_sym].compact.flatten,
        }
    end

    def hashify(user)
      {
        type: :reference,
        id: @id
      }
    end
  end

  class LookupFieldBuilder < ActionBlocks::FieldBlock
    attr_accessor :parent_reference
    references :target_field

    def before_build(parent, *args)
      @field_type = 'lookup'
      @parent_reference = parent
      mk = @parent_reference.model_key.clone
      mk['model-'] = ''
      @target_field_key = "field-#{mk}-#{args[0]}"
      @parent_model = @parent_reference.parent_model
      @id = "#{parent_reference.id}_#{args[0]}"
    end

    def after_build(parent, *args)
      @parent_model.fields.append(self)
    end

    def select_requirements(select_as_prefix = nil)
      target_data_reqs = target_field.select_requirements([select_as_prefix, parent_reference.association_name].compact.join('_'))
        {
          field_name: target_data_reqs[:field_name],
          path: [parent_reference.association_name, target_data_reqs[:path]].flatten,
        }
    end

    def match_requirements(select_as_prefix = nil)
      target_data_reqs = target_field.select_requirements([select_as_prefix, parent_reference.association_name].compact.join('_'))
        {
          path: [select_as_prefix, parent_reference.association_name, target_data_reqs[:path]].compact.flatten,
        }
    end

    def hashify(user)
      {
        type: :lookup,
        id: @id
      }
    end
  end

  class StringFieldBuilder < ActionBlocks::FieldBlock
    def before_build(parent, *args)
      super(parent, *args)
      @field_type = 'string'
    end

    def hashify(user)
      {
        type: :string,
        id: @id
      }
    end
  end

  class TextFieldBuilder < ActionBlocks::FieldBlock
    def before_build(parent, *args)
      super(parent, *args)
      @field_type = 'text'
    end

    def hashify(user)
      {
        type: :text,
        id: @id
      }
    end
  end

  class DatetimeFieldBuilder < ActionBlocks::FieldBlock
    def before_build(parent, *args)
      super(parent, *args)
      @field_type = 'datetime'
    end

    def select_requirements(select_as_prefix = nil)
      {
        field_name: [select_as_prefix,@id].compact.join('_').to_sym,
        path: [@id],
        function: -> (*args) { timezone('US/Central', *args) }
      }
    end

    def hashify(user)
      {
        type: :datetime,
        id: @id
      }
    end
  end

  class AttachmentBuilder < ActionBlocks::FieldBlock
    sets :attachment_type

    validates :attachment_type, inclusion: { in: %w(image file),
      message: "%{value} is not a valid attachment" }

    def before_build(parent, *args)
      super(parent, *args)
      @attachment_type = 'image'
      @field_type = 'attachment'
    end

    def select_requirements(select_as_prefix = nil)
      {
        field_name: [select_as_prefix,@id].compact.join('_').to_sym,
        path: [:id]
      }
    end

    def match_requirements(select_as_prefix = nil)
      raise "should not use attachment in match conditions"
      {
        path: [select_as_prefix, @id].compact
      }
    end

    def hashify(user)
      {
        type: :attachment,
        attachment_type: @attachment_type,
        id: @id,
        model_key: @parent_model.key
      }
    end
  end


  class DateFieldBuilder < ActionBlocks::FieldBlock
    def before_build(parent, *args)
      super(parent, *args)
      @field_type = 'date'
    end

    def hashify(user)
      {
        type: :date,
        id: @id
      }
    end
  end

  class IntegerFieldBuilder < ActionBlocks::FieldBlock
    def before_build(parent, *args)
      super(parent, *args)
      @field_type = 'integer'
    end

    def hashify(user)
      {
        type: :integer,
        id: @id
      }
    end
  end


end
