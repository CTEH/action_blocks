module ActionBlocks
  class TableBuilder < ActionBlocks::BlockType
    attr_accessor :workspace, :subspace, :dashboard
    block_type :table
    sets :title
    sets :scope
    sets :view
    sets :columns
    references :model
    references :selection_model
    references :selection, handler: -> (builder, model, selection) {
      builder.selection_model_key = "model-#{model}"
      builder.selection_key = "selection-#{model}-#{selection}"
    }

    builds_many :table_columns, :col, 'ActionBlocks::TableColumnBuilder'

    validates :columns, presence: true
    validates :model_key, presence: true

    validate :scope, :validate_scope
    def validate_scope
      return unless scope
      errors.add(:scope, 'requires Proc -> () {}') if scope.class != Proc
      if scope && scope.class == Proc
        valid_parameters = [%i[keyreq current_user]]
        valid_parameters << [:keyreq, dashboard.model.id.to_sym] if dashboard.model
        valid_parameters << [:keyreq, subspace.model.id.to_sym] if subspace.model
        invalid_parameters = scope.parameters - valid_parameters
        errors.add(:scope, "has invalid parameter: #{invalid_parameters}  Allowed: #{valid_parameters}") unless invalid_parameters.empty?
      end
    end

    validate :scope, :validate_selection_model
    def validate_selection_model
      if dashboard.model != selection_model && subspace.model != selection_model
        errors.add(:selection_model, "selection model not in subspace or dashboard")
      end
    end

    def before_build(parent, *args)
      @dashboard = parent
      @subspace = @dashboard.subspace
      @workspace = @subspace.workspace
      @title = id.to_s.titleize
      @id = args[0]
    end

    # Create a field reference for each column
    def after_build(_parent, *_args)
      (@columns || []).each do |c|
        @dsl_delegate.col(c)
      end
    end

    def key
      "table-#{workspace.id}_#{subspace.id}_#{dashboard.id}_#{@id}"
    end

    def allowed_columns(_user)
      model_associations = model.active_model.reflect_on_all_associations(:belongs_to)
      model_association_columns = model_associations.map { |ma| ma.name.to_s + '_id' }
      columns = [:id] + @columns + model_association_columns
      columns.uniq
    end

    def select_fields()
      [
        data_select_fields,
        view_link_select_fields
      ].flatten
    end

    def selection_match_requirements(user)
      if selection
        selection.match_reqs(user)
      else
        []
      end
    end

    def filter_requirements(user:, record:)
      filter_reqs = []
      if selection && record
        filter_reqs << selection.record_filter_reqs(user: user, record: record)
      end
      return filter_reqs.flatten
    end

    # Reason to move logic to model
    # would be to centralize user level
    # access to columns

    def data_select_fields
      @table_columns.map(&:field)
    end

    # Technical debt deep discovery
    # e.g. Subspace model being case
    #      and this model being change order

    def view_link_select_fields
      # Find dashboards in modeled subspace
      @workspace.subspaces.each do |ss|
        next unless ss.model && ss.model.id != model.id
        ss.dashboards.each do |d|
          next unless d.model && d.model.id == model.id
          ref_f = model.fields.find do |f|
            f.field_type == 'reference' &&
              f.id == model.id &&
              f.model.id == ss.model.id
          end || model.fields.find do |f|
            f.field_type == 'reference' &&
              f.model.id == ss.model.id
          end
          return [
            model.fields_hash[:id],
            model.fields_hash[ref_f.relation.join_foreign_key.to_sym]
          ].flatten
        end
      end
      [
        model.fields_hash[:id]
      ]
    end

    def hashify(_user)
      {
        title: @title,
        key: key,
        type: type,
        column_keys: allowed_columns(nil),
        view: @view,
        model_key: model.key,
        table_columns: @table_columns.map(&:hashify)
      }
    end

    # Given params subspace_model_id and/or workspace_model_id
    # Find records and create named arguments
    # If subspace_model_id was 4 and this table was in a subspace belonging to Work Order
    # arguments would be { work_order: WorkOrder.find(4) }
    def scope_args(params:, user:)
      if scope
        subspace_variable_name = subspace.model.try(:id).try(:to_sym) # returns a label such as :work_order
        dashboard_variable_name = dashboard.model.try(:id).try(:to_sym) # returns a label such as :work_order
        args = {}
        if subspace_variable_name && scope.parameters.include?([:keyreq, subspace_variable_name])
          subspace_record = subspace.model.active_model.find(params[:subspace_model_id])
          # Todo: check user has read access to subspace record
          args[subspace_variable_name] = subspace_record
        end
        if dashboard_variable_name && scope.parameters.include?([:keyreq, dashboard_variable_name])
          dashboard_record = dashboard.model.active_model.find(params[:dashboard_model_id])
          # Todo: check user has read access to dashboard_record
          args[dashboard_variable_name] = dashboard_record
        end
        if scope.parameters.include?([:keyreq, :current_user])
          args[:current_user] = user
        end
        args
      else
        {}
      end
    end

    # Given params subspace_model_id and/or workspace_model_id
    # Get the parent selection record
    def selection_record(params:, user: nil)
      if selection
        subspace_model_name = subspace.model.try(:id).try(:to_sym) # returns a label such as :work_order
        dashboard_model_name = dashboard.model.try(:id).try(:to_sym) # returns a label such as :work_order
        selection_model_name = selection.base_model.try(:id).try(:to_sym)

        if !subspace_model_name.blank? && selection_model_name == subspace_model_name
          record = subspace.model.active_model.find(params[:subspace_model_id])
        end
        if !dashboard_model_name.blank? && selection_model_name == dashboard_model_name
          record = dashboard.model.active_model.find(params[:dashboard_model_id])
        end
        if dashboard_model_name == subspace_model_name
          raise "Ambiguous model nesting.  ActionBlock validation should have prevented this."
        end
        if dashboard_model_name != selection_model_name && subspace_model_name != selection_model_name
          raise "Invalid selection model.  ActionBlock validation should have prevented this."
        end
        record
      else
        nil
      end
    end

    def to_json(params:, user:)
      if scope
        scope_to_json(params: params, user: user)
      else
        pp({
          params: params,
          user: user
        })
        builder_to_json(params: params, user: user)
      end
    end

    # Legacy Support
    def scope_to_json(params:, user:)
      if scope.parameters.length > 0
        s = scope.call(scope_args(params: params, user: user))
      else
        s = scope.call()
      end
      return s.to_json
    end

    def builder_engine(params:, user:)
      klass = model.active_model
      selection_match_reqs = selection_match_requirements(user)
      record = selection_record(params: params, user: user)
      filter_reqs = filter_requirements(user: user, record: record)

      # pp({
      #   record: record,
      #   select_fields: select_fields,
      #   selection_match_reqs: selection_match_reqs,
      #   filter_reqs: filter_reqs
      # })

      data_engine = ActionBlocks::DataEngine.new(klass,
        select_fields: select_fields,
        selection_match_reqs: selection_match_reqs,
        selection_filter_reqs: filter_reqs
      )
      data_engine
    end

    def builder_to_json(params:, user:)
      engine = builder_engine(params: params, user: user)
      return engine.to_json
    end


  end

  class TableColumnBuilder < ActionBlocks::BaseBuilder
    references :field
    def before_build(parent, *args)
      @id = args[0]
      pm = parent.model_key.dup
      pm['model-'] = ''
      @field_key = "field-#{pm}-#{@id}"
    end

    def hashify
      {
        field_key: @field_key
      }
    end
  end
end
