require 'test_helper'

class SelectionsBuilderTest < ActiveSupport::TestCase
  def setup
    ActionBlocks.unload! # Remove DSL
  end

  test 'selections are stored' do
    ActionBlocks.model :order_detail

    ActionBlocks.model :work_order do
      active_model Order
      selection :order_details
    end

    assert ActionBlocks.find('selection-work_order-order_details')
  end

  test "related models can be inferred using selection name" do
    ActionBlocks.model :order_detail

    ActionBlocks.model :work_order do
      active_model Order
      selection :order_details
    end

    selection = ActionBlocks.find('selection-work_order-order_details')
    assert_equal selection.related_model_key, 'model-order_detail'
  end

  test "related models can be specified also" do
    ActionBlocks.model :work_order do
      active_model Order
      selection :active_order_details, :order_detail
    end

    selection = ActionBlocks.find('selection-work_order-active_order_details')
    assert_equal selection.related_model_key, 'model-order_detail'
  end

  test "base model is easily accessed" do
    ActionBlocks.model :work_order do
      active_model Order
      selection :active_order_details, :order_detail
    end

    selection = ActionBlocks.find('selection-work_order-active_order_details')
    assert_equal selection.base_model.key, 'model-work_order'
  end

  test "match conditions reference fields" do
    ActionBlocks.model :order_detail do
      references :order
    end
    ActionBlocks.model :order do
      selection :order_details do
        match_condition :order, :eq, :order
      end
      references :order
    end
    selection = ActionBlocks.find('selection-order-order_details')
    match_condition = selection.match_conditions.first

    assert match_condition.base_field.key, 'field-work_order-rate_sheet'
    assert match_condition.related_field.key, 'field-order_detail-order'
  end

  test "match_conditions behave like lookup fields for base match_reqs" do
    ActionBlocks.model :order do
      active_model Order
      selection :regional_employees, :employee do
        match_condition :region, :eq, :region
      end

      references :region
    end
    selection = ActionBlocks.find('selection-order-regional_employees')
    match_condition = selection.match_conditions.first

    base_expectations = {
      path: [:region_id]
    }

    assert base_expectations, match_condition.base_match_reqs
  end

  test "match_conditions behave like normal fields for related field match_reqs" do
    ActionBlocks.model :employee do
      active_model Employee
      references :region
    end
    ActionBlocks.model :region do
      active_model Region
    end
    ActionBlocks.model :order do
      active_model Order
      selection :regional_employees, :employee do
        match_condition :region, :eq, :region
      end

      references :region
    end
    selection = ActionBlocks.find('selection-order-regional_employees')
    match_condition = selection.match_conditions.first
    base_model = :order

    base_expectations = {
      path: [Order, :region_id]
    }

    related_expectations = {
      path: [:region_id]
    }

    assert_equal base_expectations, match_condition.base_match_reqs
    assert_equal related_expectations, match_condition.related_match_reqs
  end

  test "match_conditions can use lookup fields" do
    ActionBlocks.model :order_detail do
      active_model OrderDetail
      references :order do
        lookup :employee_id
      end
    end
    
    ActionBlocks.model :order do
      active_model Order
      references :employee
    end
    
    ActionBlocks.model :employee do
      active_model Employee
      selection :order_details, :order_detail do
        match_condition :id, :eq, :order_employee_id
      end
    end

    selection = ActionBlocks.find('selection-employee-order_details')
    match_condition = selection.match_conditions.first

    base_expectations = {
      path: [Employee, :id]
    }

    related_expectations = {
      path: [:order, :employee_id]
    }

    assert_equal base_expectations, match_condition.base_match_reqs
    assert_equal related_expectations, match_condition.related_match_reqs
  end

  test "selection can provide match_requirements" do
    ActionBlocks.model :employee do
      active_model Employee
      references :region
    end

    ActionBlocks.model :region do
      active_model Region
    end

    ActionBlocks.model :order do
      active_model Order
      selection :regional_employees, :employee do
        match_condition :region_id, :eq, :region_id
      end

      references :region
    end
    selection = ActionBlocks.find('selection-order-regional_employees')

    requirements = [{
      base_path: [Order, :region_id],
      predicate: :eq,
      related_path: [:region_id]
    }]

    assert_equal requirements, selection.match_reqs
  end

  test "selection can provide match_requirements for multiple conditions" do
    ActionBlocks.model :order do
      active_model Order
      selection :similar_orders, :order do
        match_condition :customer_id, :eq, :customer_id
        match_condition :employee_id, :eq, :employee_id
      end
      references :customer
      references :employee
    end
    selection = ActionBlocks.find('selection-order-similar_orders')

    requirements = [{
      base_path: [Order, :customer_id],
      predicate: :eq,
      related_path: [:customer_id]
    },{
      base_path: [Order, :employee_id],
      predicate: :eq,
      related_path: [:employee_id]
    }]

    assert_equal requirements, selection.match_reqs
  end

  test "selection can use another selection" do
    skip
    ActionBlocks.model :change_detail do
      active_model ChangeDetail

      string :name
    end
    ActionBlocks.model :order_detail do
      active_model OrderDetail

    end
    ActionBlocks.model :work_order do
      active_model Order

      selection :order_details do
        match_condition :id, :eq, :order_detail_id
      end

      selection :items do
        match_condition :id, :eq, :order_detail_id
      end


      references :job_type do
        lookup :name
        lookup :cap
      end
    end
    selection = ActionBlocks.find('selection-work_order-rates')

    requirements = [{
      base_path: [Order, :job_type, :name],
      predicate: :eq,
      related_path: [:job_type, :name]
    },{
      base_path: [Order, :job_type, :cap],
      predicate: :eq,
      related_path: [:job_type, :cap]
    }]

    assert_equal requirements, selection.match_reqs
  end


  test "validates match conditions exist" do
    ActionBlocks.unload!
    ActionBlocks.model :order_detail do
      active_model OrderDetail
    end
    ActionBlocks.model :order do
      active_model Order
      selection :products
    end

    s1 = ActionBlocks.find('selection-order-products')
    assert s1.invalid?
  end

  test "validates match conditions don't override existing has_may conditions" do
    ActionBlocks.unload!
    ActionBlocks.model :order_detail do
      active_model OrderDetail
    end
    ActionBlocks.model :work_order do
      active_model Order
      selection :order_details do
        match_condition :id, :eq, :work_order_id
      end
    end

    s1 = ActionBlocks.find('selection-work_order-order_details')
    assert 'user_defined', s1.match_conditions_source
    assert s1.invalid?
  end

  test "selection can get match_conditions by introspecting has_many" do
    ActionBlocks.unload!
    ActionBlocks.model :order_detail do
      active_model OrderDetail
      references :order
    end
    ActionBlocks.model :order do
      active_model Order
      selection :order_details do
        match_condition :id, :eq, :order
      end
    end

    s1 = ActionBlocks.find('selection-order-order_details')
    match_reqs_manual = s1.match_reqs
    
    ActionBlocks.unload!
    ActionBlocks.model :order_detail do
      active_model OrderDetail
      references :order
    end
    # ActionBlocks.unload!
    ActionBlocks.model :order do
      active_model Order
      selection :order_details
    end

    s2 = ActionBlocks.find('selection-order-order_details')
    match_reqs_introspect = s2.match_reqs
    assert_equal match_reqs_introspect, match_reqs_manual
  end


end
