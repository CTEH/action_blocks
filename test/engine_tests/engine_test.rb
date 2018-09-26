require 'test_helper'

class EngineTest < ActiveSupport::TestCase

  setup do
    ActionBlocks.config[:should_authorize] = false
    ActionBlocks.config[:selections_engine] = ActionBlocks::SelectionsViaWhereEngine
  end

  test 'builds query' do

    d1 = FactoryBot.create :order_detail
    d2 = FactoryBot.create :order_detail

    select_reqs = [
      {
        field_name: :id, path: [:id]
      },
      {
        field_name: :ocm, path: [:order, :customer, :company]
      }
    ]

    @engine = ActionBlocks::DataEngine.new(
      OrderDetail, 
      select_reqs: select_reqs
    )

    # puts @engine.query.to_sql

    # debug @engine.query.to_sql

    results = @engine.query.all
    r1 = results.find {|r| r.id == d1.id}
    r2 = results.find {|r| r.id == d2.id}
    assert_equal r1.ocm, d1.order.customer.company
    assert_equal r2.ocm, d2.order.customer.company
  end


end
