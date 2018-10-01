module ActionBlocks
  # Data Engine
  class FilterAdapter
    attr_accessor :engine, :user, :filter_reqs

    def initialize(engine:, filter_reqs:, user:)
      @engine = engine
      @user = user
      @rls_scheme = filter_reqs
      @model_id = @engine.root_klass.to_s.underscore
    end

    # Extract fields from lisp/scheme
    def get_fields(expression)
      if expression.class == Array
        fn, *args = expression
        return [] if fn == :user
        return args.map { |a| get_fields(a) }.flatten.uniq
      end
      return expression if expression.class == Symbol
      return []
    end

    # Convert all fields to arel nodes while building up needed @engine.joins
    def get_arel_attributes()
      @fields = get_fields(@rls_scheme)
      @arel_attributes = {}
      [@fields].flatten.each do |f|
        f = ActionBlocks.find("field-#{@model_id}-#{f}")
        select_req = f.select_requirements
        if select_req[:type] == :summary
          raise "Summary fields not supported in authorizations"
        end
        field_name = select_req[:field_name]
        node, *rest = select_req[:path]
        @arel_attributes[field_name] = walk_path(@engine.root_klass, node, @engine.root_key, rest)
      end
      return @arel_attributes
    end

    def evaluate(expression)
      # Convert Symbol to Arel Attribute
      return @arel_attributes[expression] if expression.class == Symbol

      # Convert Proc to it's result
      if expression.class == Proc
        proc_args = {}
        # debug expression.parameters
        if expression.parameters.include?([:keyreq, :user])
          proc_args[:user] = @user
        end
        return expression.call(**proc_args)
      end

      # Convert expression to Arel Predicate
      if expression.class == Array
        fn, *args = expression
        case fn
        when :user
          return @user.send(args[0])
        when :eq
          left, right = args
          return evaluate(left).eq(evaluate(right))
        when :not_eq
          left, right = args
          return evaluate(left).not_eq(evaluate(right))
        when :and
          return args.map {|x| evaluate(x)}.reduce(&:and)
        when :or
          return args.map {|x| evaluate(x)}.reduce(&:or)
        else
          raise "RLS function #{fn.inspect} not recognized"
        end
      end

      return expression
    end

    def process
      if (!@rls_scheme.empty?)
        @arel_attributes = get_arel_attributes()
        @engine.wheres << evaluate(@rls_scheme)
      end
    end

    def walk_path(klass, node, parent_key, col_path)
      key = [parent_key, node].compact.join('_').to_sym
      return node if node.class != Symbol
      return @engine.tables[parent_key][node.to_sym] if col_path.empty?

      # Create Arel Table Alias
      relation = klass.reflections[node.to_s]
      klass = relation.klass
      @engine.tables[key] = klass.arel_table.alias(key) unless @engine.tables[key]
      # Create Join
      fk = relation.join_foreign_key
      pk = relation.join_primary_key
      join_on = @engine.tables[key].create_on(@engine.tables[parent_key][fk].eq(@engine.tables[key][pk]))
      @engine.joins[key] = @engine.tables[parent_key].create_join(@engine.tables[key], join_on, Arel::Nodes::OuterJoin)
      # Recurse
      next_node, *rest = col_path
      return walk_path(klass, next_node, key, rest)
    end
  end
end
