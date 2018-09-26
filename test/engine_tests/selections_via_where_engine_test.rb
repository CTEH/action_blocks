require 'test_helper'

class SelectionsViaWhereEngineTest < ActiveSupport::TestCase

  setup do
    ActionBlocks.config[:should_authorize] = false
    ActionBlocks.config[:selections_engine] = ActionBlocks::SelectionsViaWhereEngine
  end

  test 'handles simple selection scenario' do
    wo1 = FactoryBot.create :order
    2.times do
      co1 = FactoryBot.create :order_detail, order: wo1
    end
    wo2 = FactoryBot.create :order
    co2 = FactoryBot.create :order_detail, order: wo2

    ActionBlocks.model :order_detail do
      active_model OrderDetail
    end

    ActionBlocks.model :customer do
      active_model Customer
      string :company
    end

    ActionBlocks.model :order do
      active_model Order
      selection :order_details
      references :customer do
        lookup :company
      end
    end

    select_reqs = [ 
      { field_name: :id, path: [:id] }, 
    ]
    
    selection_match_reqs = [{
      base_path: [Order, :id],
      predicate: :eq,
      related_path: [:order_id]
    }]

    selection_filter_reqs = [{
      base_path: [Order, :id],
      predicate: :eq,
      related_path: [wo1.id]
    }]

    # puts selection_match_reqs

    @engine = ActionBlocks::DataEngine.new(
      OrderDetail,
      table_alias_prefix: 'sub',
      select_reqs: select_reqs,
      selection_match_reqs: selection_match_reqs,
      selection_filter_reqs: selection_filter_reqs
    )

    assert !@engine.query.all.find {|r| r.id == co2.id}
  end

end
