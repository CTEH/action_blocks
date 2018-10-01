require "action_blocks/engine"
require "action_blocks/version"
require 'action_block_loader'

module ActionBlocks

  autoload :AuthorizationBuilder, 'action_blocks/builders/authorization_builder'
  autoload :BarchartBuilder, 'action_blocks/builders/barchart_builder'
  autoload :BaseBuilder, 'action_blocks/builders/base_builder'
  autoload :BlockType, 'action_blocks/builders/block_type'
  autoload :FormBuilder, 'action_blocks/builders/form_builder'
  autoload :LayoutBuilder, 'action_blocks/builders/layout_builder'
  autoload :ModelBuilder, 'action_blocks/builders/model_builder'
  autoload :SummaryFieldAggregationFunctions, 'action_blocks/builders/summary_field_aggregation_functions'
  autoload :TableBuilder, 'action_blocks/builders/table_builder'
  autoload :WorkspaceBuilder, 'action_blocks/builders/workspace_builder'

  # autoload :AuthorizationEngine, 'action_blocks/data_engine/authorization_engine'
  autoload :AuthorizationAdapter, 'action_blocks/data_engine/authorization_adapter'
  autoload :FilterAdapter, 'action_blocks/data_engine/filter_adapter'

  autoload :DatabaseFunctions, 'action_blocks/data_engine/database_functions'
  autoload :DataEngine, 'action_blocks/data_engine/data_engine'
  autoload :FieldsEngine, 'action_blocks/data_engine/fields_engine'
  autoload :FilterEngine, 'action_blocks/data_engine/filter_engine'
  autoload :SelectionsViaWhereEngine, 'action_blocks/data_engine/selections_via_where_engine'
  autoload :SummaryEngine, 'action_blocks/data_engine/summary_engine'

  # autoload :BlocksController, 'action_blocks/app/controllers/action_blocks/blocks_controller'

  autoload :Store, 'action_blocks/store'

  class << self
    attr_accessor :block_db, :loader, :selections_engine, :config
  end

  @config = {
    fields_engine: FieldsEngine,
    selections_engine: SelectionsViaWhereEngine,
    filter_engine: FilterEngine,
    summary_engine: SummaryEngine,
    should_authorize: true,
    authorization_adapter: AuthorizationAdapter
  }

  def self.block_store
    self.block_db ||= ActionBlocks::Store.new
    return self.block_db
  end

  def self.initial_load
    Rails.application.config.after_initialize do
      self.load
    end
  end


  def self.load
    self.loader = ActionBlocks::Loader.new('app/blocks')
    self.loader.load!
    self.block_store.after_load
    self.loader.attach_reloader
    self.block_store.freeze_builders
  end

  def self.unload
    self.block_db = nil
  end

  def self.method_missing(m, *args, &block)
    self.block_store.send(m, *args, &block)
  end

end

 require 'action_blocks/error'
