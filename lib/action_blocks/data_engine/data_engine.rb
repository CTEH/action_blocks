module ActionBlocks
  # Data Engine
  class DataEngine
    def initialize(root_klass,
      user: nil,
      table_alias_prefix: nil,
      select_reqs: [],
      select_fields: [],
      filter_reqs: [],
      selection_match_reqs: [],
      selection_filter_reqs: []
    )
      @root_klass = root_klass

      select_reqs_via_fields = select_fields.map(&:select_requirements)

      if [select_reqs].length > 0
        Rails.logger.warn "Passing select_reqs to Data Engine is deprecated."
      end
      all_select_reqs = [select_reqs, select_reqs_via_fields].flatten.compact

      select_reqs_for_field_engine = all_select_reqs.select { |r| r[:type].nil? }
      select_reqs_for_summary_engine = all_select_reqs.select { |r| r[:type] == :summary }

      if ActionBlocks.config[:should_authorize]
        if user.nil?
          raise "@user must be provided to data engine when should_authorize is configured"
        end
      end
      @user = user

      @fields_engine = ActionBlocks.config[:fields_engine].new(
        @root_klass,
        user: user,
        table_alias_prefix: table_alias_prefix,
        select_reqs: select_reqs_for_field_engine
      )

      @selections_engine = ActionBlocks.config[:selections_engine].new(
        @root_klass,
        user: user,
        table_alias_prefix: table_alias_prefix,
        selection_match_reqs: selection_match_reqs,
        selection_filter_reqs: selection_filter_reqs
      )

      @filter_engine = ActionBlocks.config[:filter_engine].new(
        @root_klass,
        user: user,
        filter_reqs: filter_reqs,
      )

      @summary_engine = ActionBlocks.config[:summary_engine].new(
        @root_klass,
        user: user,
        summary_reqs: select_reqs_for_summary_engine
      )

      # if ActionBlocks.config[:should_authorize]
      #   @authorization_engine = ActionBlocks.config[:authorization_engine].new(
      #     @root_klass,
      #     user: user
      #     # table_alias_prefix: table_alias_prefix,
      #     # select_reqs: select_reqs_for_field_engine
      #   )
      # end

      process
    end

    def process
      @fields_engine.process
      @selections_engine.process
      @summary_engine.process
      @filter_engine.process
      if ActionBlocks.config[:should_authorize]
          @authorization_adapter = AuthorizationAdapter.new(engine: @fields_engine, user: @user)
          @authorization_adapter.process
      end
    end

    def to_json
      sql = query.to_sql
      jsql = "select array_to_json(array_agg(row_to_json(t)))
          from (#{sql}) t"
      ActiveRecord::Base.connection.select_value(jsql)
    end

    # Experimental
    def first_to_json
      # SELECT row_to_json(r)
      sql = query.to_sql
      jsql = "select row_to_json(t)
          from (#{sql}) t"
      ActiveRecord::Base.connection.select_value(jsql)
    end

    def query
      engine_queries = [
        @summary_engine.query,
        @selections_engine.query,
        @fields_engine.query,
        @filter_engine.query,
      ]
      engine_queries.reduce(&:merge)
    end
  end
end
