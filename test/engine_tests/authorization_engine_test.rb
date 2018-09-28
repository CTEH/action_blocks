require 'test_helper'
class AuthorizationEngineTest < ActiveSupport::TestCase

  setup do
    ActionBlocks.config[:should_authorize] = true
    ActionBlocks.unload!
    @select_reqs = { field_name: :id, path: [:id]}
  end

  test "grant role without block authorizes all" do
    user = FactoryBot.create :user, { role: :admin }
    3.times do 
        FactoryBot.create :order
    end
    ActionBlocks.model :order
    ActionBlocks.authorization Order do
        grant :admin
    end

    engine = ActionBlocks::DataEngine.new(
        Order,
        user: user,
    )

    assert_equal 3, engine.query.all.length     
  end


  test "no grant authorizes none" do
    user = FactoryBot.create :user, { role: :admin }
    3.times do 
        FactoryBot.create :order
    end
    ActionBlocks.model :order
    ActionBlocks.authorization Order do
    end

    engine = ActionBlocks::DataEngine.new(
        Order,
        user: user,
    )

    # debug engine.query.to_sql

    assert_equal 0, engine.query.all.length     
  end

  test '_eq filters correct counts depending on user' do
    @c1 = FactoryBot.create :user, { role: 'customer', customer: FactoryBot.create(:customer) }
    @c2 = FactoryBot.create :user, { role: 'customer', customer: FactoryBot.create(:customer) }

    1.times do
      FactoryBot.create :order, { customer: @c1.customer }
    end

    2.times do
      FactoryBot.create :order, { customer: @c2.customer }
    end

    ActionBlocks.model :order do
      active_model Order
      integer :customer_id
      integer :employee_id
    end

    ActionBlocks.authorization :order do
      grant :customer, _eq(:customer_id, _user(:customer_id))
    end

    e = ActionBlocks::DataEngine.new(Order, select_reqs: @select_reqs, user: @c1)
    e.process
    assert_equal 1, e.query.all.length

    e = ActionBlocks::DataEngine.new(Order, select_reqs: @select_reqs, user: @c2)
    e.process
    assert_equal 2, e.query.all.length

  end

  test '_or filters correct counts depending on user' do
    @u1 = FactoryBot.create :user, { role: 'employee', employee: FactoryBot.create(:employee) }
    @e1 = @u1.employee

    2.times do 
      # Create 2 orders by this employee but in random region
      FactoryBot.create :order, { employee: @e1 }
    end

    3.times do
      # Create 3 order in e1's region
      FactoryBot.create :order, { region: @e1.region }
    end

    4.times do
      # Create 4 random orderss
      FactoryBot.create :order
    end

    ActionBlocks.model :order do
      active_model Order
      integer :employee_id
      integer :region_id
    end

    ActionBlocks.authorization :order do
      grant :employee, _or(
        _eq(:employee_id, -> (user:) { user.employee_id }),
        _eq(:region_id, -> (user:) { user.employee.region_id })
      )
    end

    e = ActionBlocks::DataEngine.new(Order, select_reqs: @select_reqs, user: @u1)
    e.process
    assert_equal 5, e.query.all.length
  end

  test '_and filters correct counts depending on user' do
    @u1 = FactoryBot.create :user, { role: 'employee', employee: FactoryBot.create(:employee) }
    @e1 = @u1.employee

    2.times do 
      FactoryBot.create :order, { employee: @e1, region: @e1.region }
    end

    3.times do
      FactoryBot.create :order, { region: @e1.region }
    end

    5.times do
      FactoryBot.create :order, { employee: @e1 }
    end

    ActionBlocks.model :order do
      active_model Order
      integer :employee_id
      integer :region_id
    end

    ActionBlocks.authorization :order do
      grant :employee, _and(
        _eq(:employee_id, -> (user:) { user.employee_id }),
        _eq(:region_id, -> (user:) { user.employee.region_id })
      )
    end

    e = ActionBlocks::DataEngine.new(Order, select_reqs: @select_reqs, user: @u1)
    e.process
    assert_equal 2, e.query.all.length
  end

  test 'nested ands and ors filters correct counts depending on user' do
    @u1 = FactoryBot.create :user, { role: 'employee', employee: FactoryBot.create(:employee) }
    @e1 = @u1.employee

    2.times do 
      # Create 2 orders by this employee but in random region
      FactoryBot.create :order, { employee: @e1 }
    end

    3.times do
      # Create 3 order in e1's region
      FactoryBot.create :order, { region: @e1.region }
    end

    4.times do
      FactoryBot.create :order, { status: 'deleted', employee: @e1, region: @e1.region }
    end

    5.times do
      FactoryBot.create :order
    end


    ActionBlocks.model :order do
      active_model Order
      integer :employee_id
      integer :region_id
      string :status
    end

    ActionBlocks.authorization :order do
      grant :employee, _and(
        _or(
          _eq(:employee_id, -> (user:) { user.employee_id }),
          _eq(:region_id, -> (user:) { user.employee.region_id }),
        ),
        _not_eq(:status, 'deleted')
    )
    end

    e = ActionBlocks::DataEngine.new(Order, select_reqs: @select_reqs, user: @u1)
    e.process
    assert_equal 5, e.query.all.length
  end

  test 'related nested ands and ors filters correct counts depending on user' do
    @u1 = FactoryBot.create :user, { role: 'employee', employee: FactoryBot.create(:employee) }
    @e1 = @u1.employee

    2.times do 
      # Create 2 orders by this employee but in random region
      o = FactoryBot.create :order, { employee: @e1 }
      FactoryBot.create :order_detail, { order: o }
    end

    3.times do
      # Create 3 order in e1's region
      o = FactoryBot.create :order, { region: @e1.region }
      FactoryBot.create :order_detail, { order: o }
    end

    4.times do
      o = FactoryBot.create :order, { status: 'deleted', employee: @e1, region: @e1.region }
      FactoryBot.create :order_detail, { order: o }
    end

    5.times do
      o = FactoryBot.create :order
      FactoryBot.create :order_detail, { order: o }
    end

    ActionBlocks.model :order do
      active_model Order
      integer :employee_id
      integer :region_id
      string :status
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail
      references :order do
        lookup :employee_id
        lookup :region_id
        lookup :status
      end
    end

    ActionBlocks.authorization :order_detail do
      grant :employee, _and(
        _or(
          _eq(:order_employee_id, -> (user:) { user.employee_id }),
          _eq(:order_region_id, -> (user:) { user.employee.region_id }),
        ),
        _not_eq(:order_status, 'deleted')
    )
    end

    e = ActionBlocks::DataEngine.new(OrderDetail, select_reqs: @select_reqs, user: @u1)
    e.process
    # debug e.query.to_sql
    assert_equal 5, e.query.all.length
  end

  test 'Authorizes Lookup Fields' do
    admin_user = FactoryBot.create :user, { role: :admin }
    d1 = FactoryBot.create :order_detail
    d2 = FactoryBot.create :order_detail

    ActionBlocks.model :customer do
      active_model Customer
      string :company
      string :status
    end

    ActionBlocks.authorization :customer do
      grant :admin, _not_eq(:status, "deleted")
    end

    ActionBlocks.model :order do
      active_model Order
      string :status
      references :customer do
        lookup :company
      end
    end
    
    ActionBlocks.authorization :order do
      grant :admin, _not_eq(:status, "deleted")
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail
      references :order do 
        lookup :customer_company, :ocm
        lookup :status
      end
    end
    ActionBlocks.authorization :order_detail do
      grant :admin, _not_eq(:order_status, "deleted")
    end

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
      user: admin_user,
      select_reqs: select_reqs
    )

    # puts @engine.query.to_sql

    debug @engine.query.to_sql

    results = @engine.query.all
    r1 = results.find {|r| r.id == d1.id}
    r2 = results.find {|r| r.id == d2.id}
    assert_equal r1.ocm, d1.order.customer.company
    assert_equal r2.ocm, d2.order.customer.company
  end

  test 'authorization is applied to selections' do
  #   SELECT
  #   (
  #     SELECT
  #         COUNT( "sub_order_details" . "id" ) AS count_of_order_details
  #       FROM
  #         "order_details" "sub_order_details"
  #       WHERE
  #         "sub_order_details" . "id" IN (
  #           SELECT
  #               "sub_order_details" . "id"
  #             FROM
  #               "order_details" "sub_order_details"
  #               ,"orders" "sub_orders"
  #             WHERE
  #               "sub_orders" . "id" = "sub_order_details" . "order_id"
  #               AND "order_details" . "id" = "sub_order_details" . "id"
  #         )
  #         AND "sub_order_details" . "status" != 'deleted'
  #   ) count_of_order_details
  # FROM
  #   "order_details" "order_details"
  # WHERE
  #   "order_details" . "status" != 'deleted'

    user = FactoryBot.create :user, { role: :employee }

    ActionBlocks.model :order do
      active_model Order
      string :status

      selection :order_details do
        summary :count_of_order_details, -> { count }
      end
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail
      identity :id
      string :status
      references :order do
        lookup :status
      end
    end

    ActionBlocks.authorization :order_detail do
      grant :employee, _not_eq(:status, 'deleted')
    end

    ActionBlocks.authorization :order do
      grant :employee, _not_eq(:status, 'deleted')
    end

    summary_field = ActionBlocks.find('field-order-count_of_order_details')
    select_reqs = summary_field.select_requirements

    e = ActionBlocks::DataEngine.new(OrderDetail, select_reqs: select_reqs, user: user)
    e.process

    debug e.query.to_sql
  end

  test 'no duplicate joins for authorization' do
    # SELECT
    #   "order_details" . "id" AS id
    #   ,"order_details_order" . "status" AS order_status
    # FROM
    #   "order_details" "order_details" LEFT OUTER JOIN "orders" "order_details_order"
    #     ON "order_details" . "order_id" = "order_details_order" . "id"
    ActionBlocks.config[:should_authorize] = true

    user = FactoryBot.create :user, { role: :admin }

    ActionBlocks.model :order do
      active_model Order
      string :status
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail
      references :order do
        lookup :status
      end
    end

    ActionBlocks.authorization :order_detail do
      grant :admin, _not_eq(:order_status, 'deleted')
    end

    select_reqs = [{ field_name: :id, path: [:id]}, { field_name: :order_status, path: [:order, :status] }]

    e = ActionBlocks::DataEngine.new(OrderDetail, select_reqs: select_reqs, user: user)
    e.process

    debug e.query.to_sql
    assert_equal 1, e.query.to_sql.scan(/LEFT OUTER JOIN/).count

    ActionBlocks.config[:should_authorize] = false
  end


end
