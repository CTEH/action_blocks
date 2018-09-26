module ActionBlocks
  class DatabaseFunctions
    # methods define their own params, always followed by current node and current user
    def timezone(tz, node, user, *args)
      utc = Arel::Nodes::NamedFunction.new(
        'timezone',
        [Arel::Nodes.build_quoted('UTC'), node]
      )

      Arel::Nodes::NamedFunction.new(
        'timezone',
        [Arel::Nodes.build_quoted(tz), utc]
      )
    end

    def count(node, *args)
      Arel::Nodes::NamedFunction.new(
        'count',
        [node]
      )
    end

    def string_agg(delimiter, node, *args)
      Arel::Nodes::NamedFunction.new(
        'string_agg',
        [node, Arel::Nodes.build_quoted(delimiter)]
      )
    end

    def every(predicate, value, node, *args)
      every_part = Arel::Nodes::NamedFunction.new(
        'every',
        [node.send(predicate, Arel::Nodes.build_quoted(value))]
      )

      Arel::Nodes::NamedFunction.new('CAST', [every_part.as('TEXT')])
    end
  end
end
