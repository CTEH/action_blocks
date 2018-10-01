require 'test_helper'

class FormTest < ActiveSupport::TestCase
  def setup
    ActionBlocks.config[:should_authorize] = false
    ActionBlocks.unload! # Remove DSL
  end

  test "validates valid references to models" do
    ActionBlocks.model :order
    ActionBlocks.form :standar_preview do
      model :order
    end

    assert ActionBlocks.find('form-standar_preview').valid?
  end

  test "invalidates invalid references to models" do
    ActionBlocks.model :order
    ActionBlocks.form :standar_preview do
      model :bad_reference
    end

    assert ActionBlocks.find('form-standar_preview').invalid?
  end

  test "references to model auto-resolve" do
    ActionBlocks.model :order do
      active_model Order
    end
    ActionBlocks.form :abc do
      model :order
    end
    assert ActionBlocks.find('form-abc').model.active_model == Order
  end

  # DSL Removed intentionally
  # test "reference to model in reference field auto-resolves" do
  #   ActionBlocks.model :order do
  #     active_model Order
  #   end
  #   ActionBlocks.model :change_order do
  #     active_model ChangeOrder
  #   end
  #   ActionBlocks.form :abc do
  #     model :change_order
  #     section :my_section do
  #       reference :order
  #     end
  #   end
  #   assert ActionBlocks.find('form-abc').sections.first.fields.first.model.active_model == Order
  # end

  test "forms know their form_fields and model_fields" do
    ActionBlocks.model :order do
      active_model Order
      string :applicant_num
    end
    ActionBlocks.form :abc do
      model :order
      section :overview do
        field :id
      end
    end
    # form fields have reference to the model_field
    assert 'field-order-id', ActionBlocks.find('form-abc').form_fields.first.field_key
    assert 'field-order-id', ActionBlocks.find('form-abc').model_fields.first.key
  end

  test "form provides select_reqs for fields on form" do
    user = FactoryBot.create :user
    ActionBlocks.model :customer do
      active_model Customer
      name_field :company
      string :company
    end
    ActionBlocks.model :order do
      active_model Order
      references :customer
    end
    ActionBlocks.form :abc do
      model :order
      section :overview do
        field :customer
      end
    end

    select_reqs = ActionBlocks.find('form-abc').select_reqs(user: user)

    customer_select_req = select_reqs.find {|sr| sr[:field_name]==:customer}
    assert customer_select_req
    assert_equal [:customer, :company], customer_select_req[:path]
  end

  test "form provides filter_reqs given a record" do
    user = FactoryBot.create :user
    wo = FactoryBot.create :order

    ActionBlocks.model :order do
      active_model Order
      references :customer
    end
    ActionBlocks.form :abc do
      model :order
      section :overview do
        field :customer
      end
    end

    filter_reqs = ActionBlocks.find('form-abc').filter_reqs(user: user, record_id: wo.id)
    expected_reqs = [:eq, :id, wo.id]

    assert_equal expected_reqs, filter_reqs
  end

  test "form returns correct records" do
   
    user = FactoryBot.create :user
    wo1 = FactoryBot.create :order
    wo2 = FactoryBot.create :order
    wo3 = FactoryBot.create :order


    ActionBlocks.model :order do
      active_model Order
    end
    ActionBlocks.form :abc do
      model :order
      section :overview do
        field :id
      end
    end

    form = ActionBlocks.find('form-abc')
    assert_equal wo1.id, form.record_engine(user: @user, record_id: wo1.id).query.first.id
    assert_equal wo2.id, form.record_engine(user: @user, record_id: wo2.id).query.first.id
    assert_equal wo3.id, form.record_engine(user: @user, record_id: wo3.id).query.first.id
  end


end
