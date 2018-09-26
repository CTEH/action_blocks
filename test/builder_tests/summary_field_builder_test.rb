require 'test_helper'

class SummaryFieldBuilderTest < ActiveSupport::TestCase
  def setup
    ActionBlocks.unload! # Remove DSL
  end

  test 'summaries are stored' do
    ActionBlocks.model :order do
      active_model Order
      references :customer
    end
    
    ActionBlocks.model :customer do
      active_model Customer
      selection :orders do
        summary :count_of_orders, :id, :count
      end
    end

    assert ActionBlocks.find('field-customer-count_of_orders')
  end

  test'summary can provide select requirements' do
    ActionBlocks.model :order do
      active_model Order
      references :customer
    end
    
    ActionBlocks.model :customer do
      active_model Customer
      selection :orders do
        summary :count_of_orders, -> { count }
      end
    end

    summary_field = ActionBlocks.find('field-customer-count_of_orders')
    assert_not_nil summary_field.select_requirements
  end

  test'summary has to provide valid aggregation' do
    skip 'Validation not implemented yet'
    ActionBlocks.model :order do
      active_model Order
      references :customer
    end
    
    ActionBlocks.model :customer do
      active_model Customer
      selection :orders do
        summary :count_of_orders, :id, :unknownaggregation
      end
    end

    summary_field = ActionBlocks.find('field-customer-count_of_orders')
    assert summary_field.invalid?
  end

  test'summary has to reference existing field' do
    skip 'Validation not implemented yet'
    ActionBlocks.model :order do
      active_model Order
      references :customer
    end
    
    ActionBlocks.model :customer do
      active_model Customer
      selection :orders do
        summary :count_of_orders, :doesnotexist, :count
      end
    end

    summary_field = ActionBlocks.find('field-customer-count_of_orders')
    # pp ActionBlocks.errors
    assert summary_field.invalid?
  end

  test 'summary can have filters' do
    ActionBlocks.model :order do
      active_model Order
      string :status

      references :customer
    end
    
    ActionBlocks.model :customer do
      active_model Customer
      selection :orders do
        summary :count_of_paid_orders, ->{ count() } do
          filter 'paid', :eq, :status
        end
      end
    end

    summary_field = ActionBlocks.find('field-customer-count_of_paid_orders')
    # pp summary_field.select_requirements
    assert_not_nil summary_field.select_requirements[:filter_reqs]
  end

  test 'alternative syntax for aggregate function' do
    ActionBlocks.model :order do
      active_model Order
      string :status
      string :num

      references :customer
    end
    
    ActionBlocks.model :customer do
      active_model Customer
      selection :orders do
        summary :count_of_orders, ->{ count() }
        summary :concat_of_order_num, -> { concat(:num, ',') }
      end
    end

    summary_field = ActionBlocks.find('field-customer-count_of_orders')
    # debug summary_field.select_requirements
    summary_field = ActionBlocks.find('field-customer-concat_of_order_num')
    # debug summary_field.select_requirements
  end
end
