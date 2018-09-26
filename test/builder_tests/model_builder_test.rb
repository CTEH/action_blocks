require 'test_helper'

class ModelTest < ActiveSupport::TestCase
  def setup
    ActionBlocks.unload! # Remove DSL
  end

  test "Model's active_model is an ActiveRecord class" do
    ActionBlocks.model :order do
      active_model Order
    end
    assert !ActionBlocks.has_error_for("ModelBuilder", :active_model)
  end

  test "Model's validate active_model" do
    ActionBlocks.model :order do
      active_model 'abc'
    end
    assert ActionBlocks.has_error_for("ModelBuilder", :active_model)
  end

  test "fields creates keys using model" do
    ActionBlocks.model :order do
      string :num
    end
    m = ActionBlocks.find('model-order')
    assert_equal 'field-order-num', ActionBlocks.find('model-order').fields.first.key
  end

  test "name_field creates name_field_key" do
    ActionBlocks.model :order do
      name_field :num
    end
    m = ActionBlocks.find('model-order')
    assert_equal 'field-order-num', m.name_field_key
  end

  test "name_field must refer to valid field" do
    ActionBlocks.model :order do
      name_field :num
    end
    assert ActionBlocks.has_error_for("ModelBuilder", :name_field)
  end

  test "name_fields are valid when they refer to valid fields" do
    ActionBlocks.model :order do
      name_field :num
      string :num
    end
    assert !ActionBlocks.has_error_for("ModelBuilder", :name_field)
  end

  test "fields can be found by key" do
    ActionBlocks.model :order do
      string :num
      datetime :order_date
      text :ship_address1
      date :shipped_date
    end
    assert ActionBlocks.find('field-order-num')
    assert ActionBlocks.find('field-order-order_date')
    assert ActionBlocks.find('field-order-shipped_date')
    assert ActionBlocks.find('field-order-ship_address1')
  end

  test "reference fields can be found by key" do
    ActionBlocks.model :order_detail do
      references :order
    end

    assert ActionBlocks.find('field-order_detail-order')
  end

  test "lookup fields can be found by key" do
    ActionBlocks.model :order_detail do
      references :order do
        lookup :description
      end
    end

    assert ActionBlocks.find('field-order_detail-order_description')
  end

  test "lookup fields are added to the model fields" do
    ActionBlocks.model :order_detail do
      references :order do
        lookup :status
      end
    end

    # puts ActionBlocks.find('model-order_detail').fields_hash.keys
    assert ActionBlocks.find('model-order_detail').fields_hash['order_status']
  end

  test "model can inform select requirements for a simple field" do
    ActionBlocks.model :order_detail do
      active_model OrderDetail
      string :status
    end

    field = ActionBlocks.find('model-order_detail').fields_hash[:status]
    # puts field.select_requirements
    expected = {
      field_name: :status,
      path: [:status] }
    assert_equal expected, field.select_requirements
  end

  test "model can inform select requirements for a single-step lookup field" do
    ActionBlocks.model :order do
      active_model Order
      string :num
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail

      references :order do
        lookup :num
      end
    end

    field = ActionBlocks.find('model-order_detail').fields_hash['order_num']
    # puts field.select_requirements
    expected = {
      field_name: :order_num,
      path: [:order, :num]}
    assert_equal expected, field.select_requirements
  end

  test "model can inform select requirements for a multi-step lookup field" do

    ActionBlocks.model :customer do
      active_model Customer
      string :company
    end
    
    ActionBlocks.model :order do
      active_model Order

      references :customer do
        lookup :company
      end
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail

      references :order do
        lookup :customer_company
      end
    end

    field = ActionBlocks.find('model-order_detail').fields_hash['order_customer_company']
    # puts field.select_requirements
    expected = {
      field_name: :order_customer_company,
      path: [:order, :customer, :company]}
    assert_equal expected, field.select_requirements
  end

  test "lookup field auto resolved reference to target field" do
    ActionBlocks.model :order do
      active_model Order
      string :num
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail
      references :order do
        lookup :num
      end
    end

    assert ActionBlocks.find('model-order_detail').fields_hash['order_num'].target_field
  end

  test "lookup field can only reference existing field" do
    ActionBlocks.model :order do
      active_model Order
      string :num
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail
      references :order do
        lookup :i_do_not_exist
      end
    end

    assert ActionBlocks.has_error_for("LookupFieldBuilder", :target_field)
  end

  test "target model for reference field validates on valid relationship" do
    ActionBlocks.model :order do
      active_model Order
      string :num
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail
      references :order do
        lookup :num
      end
    end

    assert !ActionBlocks.has_error_for("ReferenceFieldBuilder", :association_name)
  end

  test "target model for reference field needs to have belongs_to relationship to current model" do
    ActionBlocks.model :order do
      active_model Order
      string :num
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail
      references :bad_assoc, :order do
        lookup :num
      end
    end
    assert ActionBlocks.has_error_for("ReferenceFieldBuilder", :association_name)
  end

  test "model can provide select requirements for all fields" do
    ActionBlocks.model :order do
      active_model Order
      name_field :num
      string :num
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail
      references :order do
        lookup :num
      end
    end

    model = ActionBlocks.find('model-order_detail')

    expected = [
      {
        :field_name=>:order_id,
        :path=>[:order_id]
      },
      {
        field_name: :order_num,
        path: [:order, :num]
      },
      {:field_name=>:order, :path=>[:order, :num]},
      {:field_name=>:id, :path=>[:id]}

    ]

    assert_equal expected, model.select_requirements
  end

  test "model can provide select requirements for field selection" do
    ActionBlocks.model :order do
      active_model Order
      name_field :num
      string :num
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail
      string :num
      references :order do
        lookup :num
      end
    end

    model = ActionBlocks.find('model-order_detail')
    expected = [
      {
        field_name: :order_num,
        path: [:order, :num]
      }
    ]
    model_select_reqs = model.select_requirements([:order_num])
    assert_equal expected, model_select_reqs
  end

end
