module ActionBlocks
  # Data Engine
  class FieldsEngine
    attr_accessor :tables, :root_klass, :select_reqs, :selects, :joins,
                  :root_key, :joins, :wheres

    def initialize(root_klass, user: nil, table_alias_prefix:, select_reqs: [])
      @root_klass = root_klass
      @user = user
      @table_alias_prefix = table_alias_prefix
      @select_reqs = select_reqs
      @tables = {}
      @selects = []
      @joins = {}
      @wheres = []
    end

    def process
      root_table = @root_klass.arel_table.alias([@table_alias_prefix, @root_klass.to_s.underscore.pluralize].compact.join('_'))
      @root_key = [@table_alias_prefix, @root_klass.to_s.underscore.pluralize].compact.join('_').to_sym

      # Add base table to tables
      @tables[@root_key.to_sym] = root_table

      # Add needed relations to tables
      @select_reqs.each do |selectreq|
        # binding.pry
        colname = selectreq[:field_name]
        colpath = selectreq[:path]
        function = selectreq[:function]
        node, *rest = colpath
        walk_colpath(@root_klass, node, @root_key, rest, colname, function)
      end
    end

    def walk_colpath(klass, node, parent_key, col_path, colname, function)
      key = [@table_alias_prefix, parent_key, node].compact.join('_').to_sym
      if !col_path.empty?

        next_klass = create_table_and_joins(klass, node, key, parent_key)

        # Recurse
        next_node, *rest = col_path
        walk_colpath(next_klass, next_node, key, rest, colname, function)
      else
        # Create Arel Select
        select = if function.nil?
                   @tables[parent_key][node.to_sym].as(colname.to_s)
                 else
                   DatabaseFunctions.new.instance_exec(@tables[parent_key][node.to_sym], @user, &function).as(colname.to_s)
                 end

        @selects << select
      end
    end

    def params_to_arel(aggregate_params)
      aggregate_params.map { |param| param.is_a?(String) ? Arel::Nodes.build_quoted(param) : param } if aggregate_params
    end

    def create_table_and_joins(klass, node, key, parent_key, join_prefix = nil, associations = nil)
      # Create Arel Table Alias
      relation = klass.reflections[node.to_s] if node.is_a? Symbol
      unless @tables[key]
        @tables[key] = (relation ? relation.klass : node).arel_table.alias(key) unless @tables[key]

        # Create Join
        fk = associations ? associations[parent_key.to_s][:foreign_key] : relation.join_foreign_key
        pk = associations ? associations[parent_key.to_s][:primary_key] : relation.join_primary_key
        join_on = @tables[key].create_on(@tables[parent_key][fk].eq(@tables[key][pk]))
        @joins[join_prefix ? [join_prefix, node.to_s.underscore].compact.join('_').to_sym : key] = @tables[parent_key].create_join(@tables[key], join_on, Arel::Nodes::OuterJoin)
      end

      relation ? relation.klass : node
    end

    def selects
      @selects
    end

    def ordered_joins
      @joins.values
    end

    def froms
      @root_klass.arel_table.alias([@table_alias_prefix, @root_klass.to_s.underscore.pluralize].compact.join('_'))
    end

    def wheres
      @wheres
    end

    def query
      @root_klass
        .from(froms)
        .select(selects)
        .joins(ordered_joins)
        .where(wheres.compact.reduce(&:and))
    end


  end
end
