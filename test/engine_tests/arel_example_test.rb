require 'test_helper'

class ArelExampleTest < ActiveSupport::TestCase
  test "simple arel example doesn't error" do
    # TABLES
    customers = Customer.arel_table.alias('customer')
    referral_customers = Customer.arel_table.alias('referral_customer')
    orders = Order.arel_table

    # JOINS
    customer_on = customers.create_on(orders[:customer_id].eq(customers[:id]))
    customer_join = orders.create_join(customers, customer_on, Arel::Nodes::OuterJoin)

    referred_on = referral_customers.create_on(orders[:referred_by_id].eq(referral_customers[:id]))
    referred_join = orders.create_join(referral_customers, referred_on, Arel::Nodes::OuterJoin)

    # SELECTS
    selects = [
      orders[:num].as('order_number'),
      customers[:last_name].as('customer_last_name'),
      referral_customers[:last_name].as('referred_by_last_name')
    ]

    # SQL
    query = Order
            .select(selects)
            .joins(customer_join, referred_join)

    # SELECT
    #   "orders" . "num" AS order_number
    #   ,"customer" . "last_name" AS customer_last_name
    #   ,"referral_customer" . "last_name" AS referred_by_last_name
    # FROM
    #   "orders" LEFT OUTER JOIN "customers" "customer"
    #     ON "orders" . "customer_id" = "customer" . "id" LEFT OUTER JOIN "customers" "referral_customer"
    #     ON "orders" . "referred_by_id" = "referral_customer" . "id"

    ActiveRecord::Base.connection.execute(query.to_sql)
  end

  
  test "arel example for match conditions doesn't error" do
    # TABLES
    employee = Employee.arel_table
    employee_orders = Order.arel_table.alias('employee_orders')

    # JOINS
    employee_on = employee.create_on(employee_orders[:region_id].eq(employee[:region_id]))
    employee_join = employee.create_join(employee_orders, employee_on, Arel::Nodes::OuterJoin)

    # SELECTS
    selects = [
      employee[:department].as('department'),
    ]

    # SQL
    query = Employee
            .select(selects)
            .joins(employee_join)

    ActiveRecord::Base.connection.execute(query.to_sql).count
  end

  # SELECT
  #   "employees" . "department" AS department
  # FROM
  #   "employees" LEFT OUTER JOIN "orders" "employee_orders"
  #     ON "employee_orders" . "region_id" = "employees" . "region_id"
end
