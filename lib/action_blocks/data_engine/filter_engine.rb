module ActionBlocks
  # Data Engine
  class FilterEngine
    attr_accessor :tables, :root_klass, :root_key, :froms, :joins, :wheres,
                  :selects, :joins, :filter_reqs

    def initialize(root_klass, user: nil, filter_reqs: [])
      @root_klass = root_klass
      @filter_reqs = filter_reqs
      @tables = {}
      @joins = {}
      @wheres = []
      @froms = []
    end

    def process
      @root_table = @root_klass.arel_table
      @root_key = @root_klass.to_s.underscore.to_sym

      # Add base table to tables
      @tables[@root_key.to_sym] = @root_table

      [@filter_reqs].flatten.each do |matchreq|
        node, *rest = matchreq[:path1]
        # puts "base node: #{node} rest #{rest}"
        base_expression = walk_filter_path(@root_klass, node, @root_key, rest)

        node, *rest = matchreq[:path2]
        # puts "related node: #{node} rest #{rest}"
        related_expression = walk_filter_path(@root_klass, node, @root_key, rest)

        if base_expression.class.ancestors.include?(Arel::Attributes::Attribute)
          where = base_expression.send(matchreq[:predicate], related_expression)
        else
          where = related_expression.send(matchreq[:predicate], base_expression)
        end
        @wheres << where

      end

    end

    def walk_filter_path(klass, node, parent_key, col_path)
      key = [parent_key, node].compact.join('_').to_sym
      if node.class != Symbol
        return node
      end
      if !col_path.empty?
        # Create Arel Table Alias
        relation = klass.reflections[node.to_s]
        klass = relation.klass
        @tables[key] = klass.arel_table.alias(key) unless @tables[key]
        # Create Join
        fk = relation.join_foreign_key
        pk = relation.join_primary_key
        join_on = @tables[key].create_on(@tables[parent_key][fk].eq(@tables[key][pk]))
        @joins[key] = @tables[parent_key].create_join(@tables[key], join_on, Arel::Nodes::OuterJoin)
        # Recurse
        next_node, *rest = col_path
        return walk_filter_path(klass, next_node, key, rest)
      else
        # Return expression
        # puts "parent_key: #{node.to_sym}"
        # puts "node: #{node.to_sym}"
        return @tables[parent_key][node.to_sym]
      end
    end

    def froms
      []
    end

    def ordered_joins
      @joins.values
    end

    def wheres
      @wheres.reduce(&:and)
    end

    def query
      @root_klass
        .from(froms)
        .joins(ordered_joins)
        .where(wheres)
    end
  end
end
