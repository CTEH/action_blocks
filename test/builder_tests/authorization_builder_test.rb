require 'test_helper'

class AuthorizationTest < ActiveSupport::TestCase
  def setup
    ActionBlocks.unload! # Remove DSL
    @admin = FactoryBot.create :user, role: :admin
    @select_reqs = [{ field_name: :id, path: [:id] }]
    @filter_reqs = []
  end

  test "authorization block has active_model set" do
    ActionBlocks.model :order
    ActionBlocks.authorization Order

    assert_equal Order, ActionBlocks.find('authorization-order').active_model
  end

  test "grants are defined for a specific role" do
    ActionBlocks.model :order
    ActionBlocks.authorization Order do
      grant :admin
    end

    assert_equal :admin, ActionBlocks.find('rls-order-admin').role
  end

  test "grants define access filters" do
    ActionBlocks.model :order
    ActionBlocks.authorization Order do
      grant :admin, _eq(:customer_name, _user(:company_name))
    end

    assert_not_nil ActionBlocks.find('rls-order-admin').scheme
  end

  test "grants translates access filters to nested array" do
    ActionBlocks.model :order
    ActionBlocks.authorization Order do
      grant :admin, 
        _and(
          _or(
            _eq(:customer_company, _user(:company)),
            _eq(:customer_otherfield,  _user(:something))
          ),
          _eq(:customer_thirdfield, _user(:blah))
        )
    end

    assert_equal(
      [:and, 
        [:or, 
          [:eq, :customer_company, [:user, :company]],
          [:eq, :customer_otherfield, [:user, :something]]
        ],
        [:eq, :customer_thirdfield, [:user, :blah]]
      ], 
      ActionBlocks.find('rls-order-admin').scheme)
  end

end
