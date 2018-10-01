module ActionBlocks
  # Data Engine
  class SummaryEngine
    attr_accessor :tables, :root_klass, :summary_reqs, :selects, :joins

    def initialize(root_klass, user: nil, summary_reqs: [])
      @root_klass = root_klass
      @tables = {}

      @user = user

      @selects = []

      @summary_reqs = summary_reqs
    end

    def process
      root_table = @root_klass.arel_table.alias(@root_klass.to_s.underscore.pluralize)
      sub_table = @root_klass.arel_table.alias(['sub', @root_klass.to_s.underscore.pluralize].join('_'))

      @summary_reqs.each do |summaryreq|
        select_reqs = [summaryreq[:select_req]]
        match_reqs = summaryreq[:match_reqs]
        filter_reqs = summaryreq[:filter_reqs]

        @fields_engine = ActionBlocks.config[:fields_engine].new(
          summaryreq[:root_klass],
          table_alias_prefix: 'sub',
          select_reqs: select_reqs
        )

        # @selections_engine = SelectionsViaJoinsEngine.new(
        @selections_engine = ActionBlocks.config[:selections_engine].new(
          summaryreq[:root_klass],
          table_alias_prefix: 'sub',
          selection_match_reqs: match_reqs,
          selection_filter_reqs: filter_reqs,
          additional_where: root_table[:id].eq(sub_table[:id])
        )

        @fields_engine.process
        @selections_engine.process

        if ActionBlocks.config[:should_authorize]
          @authorization_adapter = AuthorizationAdapter.new(engine: @fields_engine, user: @user)
          @authorization_adapter.process
        end

        sub_query = summaryreq[:root_klass]
                    .from([
                      @fields_engine.froms,
                      @selections_engine.froms,
                    ].flatten.uniq)
                    .select(@fields_engine.selects)
                    .joins([
                      @selections_engine.ordered_joins,
                      @fields_engine.ordered_joins
                    ].flatten.compact)
                    .where([@selections_engine.wheres, @fields_engine.wheres].flatten.compact.reduce(&:and))
                    .as(summaryreq[:select_req][:field_name].to_s)

        @selects << sub_query
      end

    end

    def query
      @root_klass
        .select(@selects)
    end
  end
end
