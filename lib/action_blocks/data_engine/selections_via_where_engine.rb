module ActionBlocks
  # Data Engine
  class SelectionsViaWhereEngine
    attr_accessor :tables, :root_klass, :selection_match_reqs, :selects, :joins, :selection_filter_reqs

    def initialize(root_klass, user: nil, table_alias_prefix: nil, type: :many_to_many, selection_filter_reqs: [], selection_match_reqs: [], additional_where: nil)
      @root_klass = root_klass
      @table_alias_prefix = table_alias_prefix
      @tables = {}
      @joins = {}
      @wheres = []
      @froms = []
      @type = type

      @additional_where = additional_where

      # I named them selection_match_reqs because
      # the DataEngine may work with match_reqs in
      # different contexts.  It may use them for
      # summary fields or it may use them for
      # a filtering a query to the children of some
      # base models 'children'
      @selection_match_reqs = selection_match_reqs
      @selection_filter_reqs = selection_filter_reqs
    end

    def process
      @root_table = @root_klass.arel_table.alias([@table_alias_prefix, @root_klass.to_s.underscore.pluralize].compact.join('_'))
      root_key = [@table_alias_prefix, @root_klass.to_s.underscore.pluralize].compact.join('_').to_sym

      @froms << @root_table
      # Add base table to tables
      @tables[root_key.to_sym] = @root_table

      [@selection_match_reqs, @selection_filter_reqs].flatten.compact.each do |matchreq|
        node, *rest = matchreq[:base_path]
        # puts "base node: #{node} rest #{rest}"
        base_expression = walk_selection_match_path(@root_klass, node, root_key, rest)

        node, *rest = matchreq[:related_path]
        # puts "related node: #{node} rest #{rest}"
        related_expression = walk_selection_match_path(@root_klass, node, root_key, rest)

        where = if base_expression.class.ancestors.include?(Arel::Attributes::Attribute)
                  base_expression.send(matchreq[:predicate], related_expression)
                else
                  related_expression.send(matchreq[:predicate], base_expression)
                end
        @wheres << where
      end
    end

    def walk_selection_match_path(klass, node, parent_key, col_path)
      # puts "klass: #{klass} node: #{node} parent_key #{parent_key.inspect} col_path #{col_path.inspect}"
      # pp [key, rest_col_path]
      key = if node.class == Class
              [@table_alias_prefix, node.to_s.underscore.pluralize].compact.join('_').to_sym
            else
              [@table_alias_prefix, parent_key, node].compact.join('_').to_sym
            end
      return node if node.class != Symbol && node.class != Class
      if !col_path.empty?
        # Create Arel Table Alias
        if node.class != Class
          relation = klass.reflections[node.to_s]
          klass = relation.klass
          @tables[key] = klass.arel_table.alias(key) unless @tables[key]
          # Create Join
          fk = relation.join_foreign_key
          pk = relation.join_primary_key
          join_on = @tables[key].create_on(@tables[parent_key][fk].eq(@tables[key][pk]))
          @joins[key] = @tables[parent_key].create_join(@tables[key], join_on, Arel::Nodes::OuterJoin)
        else
          klass = node
          unless @tables[key]
            @tables[key] = klass.arel_table.alias(key) unless @tables[key]
            @froms << @tables[key]
          end
        end
        # Recurse
        next_node, *rest = col_path
        return walk_selection_match_path(klass, next_node, key, rest)
      else
        # Return expression
        # puts "parent_key: #{node.to_sym}"
        # puts "node: #{node.to_sym}"
        return @tables[parent_key][node.to_sym]
      end
    end


    def froms
      if @type == :many_to_many
        [@root_table]
      else
        @froms
      end
    end

    def ordered_joins
      if @type == :many_to_many
        []
      else
        @joins.values
      end
    end

    def wheres
      @wheres << @additional_where if @additional_where
      if @type == :many_to_many && (!@selection_match_reqs.empty? || !@selection_filter_reqs.empty?)
        subquery_arel = subquery_for_many_to_many_selections.arel
        # w = Arel::Nodes::In.new(@root_table[:id], subquery.ast)
        @root_table[:id].in(subquery_arel)
      else
        @wheres.reduce(&:and)
      end
    end

    def subquery_for_many_to_many_selections
      # Arel::Distinct.new(@rook_klasas[:id])
      @root_klass
        .from([@froms].flatten)
        .select(@root_table[:id])
        .joins(@joins.values)
        .where(@wheres.reduce(&:and))
    end

    def query
      @root_klass
       .joins(ordered_joins)
        .where(wheres)
    end
  end
end
