module ActionBlocks

  class FormBuilder < ActionBlocks::BlockType
    attr_accessor :form_fields, :model_id, :model_fields, :form_fields_hash, :model_fields_hash
    block_type :form
    references :model, handler: -> (form_builder, model_id) do
      form_builder.model_key = "model-#{model_id}"
      form_builder.model_id = model_id
    end

    builds_many :sections, :section, 'ActionBlocks::FormSectionBuilder'

    def before_build(parent, *args)
      @form_fields = []
      @form_fields_hash = {}
    end

    def add_form_field(ff)
      name = ff.id
      @form_fields << ff
      @form_fields_hash[name] = ff
    end

    def model_fields
      @form_fields.map { |ff| ff.field }
    end

    def record_engine(user:, record_id:)
      DataEngine.new(model.active_model,
        filter_reqs: filter_reqs(user: user, record_id: record_id),
        select_reqs: select_reqs(user: user)
      )
    end

    def record_to_json(user:, record_id:)
      record_engine(user: user, record_id: record_id).first_to_json
    end

    def select_reqs(user:)
      srs = model_fields.map {|mf| mf.select_requirements }.flatten
    end

    def filter_reqs(user:, record_id:)
      model.filter_reqs(user: user, record_id: record_id)
    end

    def hashify(user)
      {
        context: @context,
        sections: @sections.map {|s| s.hashify(user)},
        key: key,
        type: type
      }
    end

  end

  # Section

  class FormSectionBuilder < ActionBlocks::BaseBuilder
    attr_accessor :form
    sets :width
    sets :title
    builds_many :fields, :field, 'ActionBlocks::FormFieldBuilder'

    def before_build(parent, *args)
      @form = parent
      @title = args[0].to_s.titleize
      @width = 4
      @label = @field.to_s.titleize
    end

    def hashify(user)
      {
        title: @title,
        width: @width,
        fields: @fields.map {|f| f.hashify(user)},
      }
    end
  end

  # Field

  class FormFieldBuilder < ActionBlocks::BaseBuilder
    attr_accessor :name, :form, :section
    references :field
    sets :width
    sets :label
    sets :label_above

    def before_build(parent, *args)
      @section = parent
      @form = @section.form
      @name = args[0]
      @field_key = "field-#{@form.model_id}-#{@name}"
      @width = parent.width
      @label = @name.to_s.titleize
      @label_above = false
    end

    def after_build(*args)
      @form.add_form_field(self)
    end

    def hashify(user)
      {
        type: 'field',
        field_key: @field_key,
        label_above: @label_above,
        label: @label,
        width: @width,
      }
    end
  end


end
