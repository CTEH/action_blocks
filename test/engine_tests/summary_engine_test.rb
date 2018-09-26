require 'test_helper'

class SummaryEngineTest < ActiveSupport::TestCase

  setup do
    ActionBlocks.config[:should_authorize] = false
    ActionBlocks.config[:selections_engine] = ActionBlocks::SelectionsViaWhereEngine
    ActionBlocks.config[:summary_engine] = ActionBlocks::SummaryEngine
  end

  test 'summary engine can select summary fields' do
    5.times do
      r = FactoryBot.create :region
      rs1 = FactoryBot.create :order, region: r
      rand(5).times do
        FactoryBot.create :employee, region: r
      end
    end

    select_reqs = [
      { field_name: 'id', path: [:id] },
    #   { field_name: 'rate_sheet_name', path: %i[rate_sheet name] }
    ]

    summary_reqs = [{
      type: :summary,
      root_klass: Employee,
      select_req: { field_name: :count_of_region_employees, path: [:id], function: ->(*args) { count(*args) } },
      match_reqs: [{
        base_path: [Order, :region_id], # order
        predicate: :eq,
        related_path: [:region_id]   # employee
      }]
    }]

    @engine = ActionBlocks::DataEngine.new(
      Order,
      select_reqs: [select_reqs, summary_reqs].flatten
    )

    # puts @engine.query.to_sql

    results = @engine.query.all

    Order.all.each do |order|
      assert_equal order.region.employees.count, results.find { |r| r['id'] == order.id }['count_of_region_employees']
    end
  end

  test 'summary fields do not interfere with field selections that require joins' do
    5.times do
      r = FactoryBot.create :region
      rs1 = FactoryBot.create :order, region: r
      rand(5).times do
        FactoryBot.create :employee, region: r
      end
    end

    select_reqs = [
      { field_name: 'id', path: [:id] },
      { field_name: 'region_title', path: %i[region title] }
    ]

    summary_reqs = [{
      type: :summary,
      root_klass: Employee,
      select_req: { field_name: :count_of_region_employees, path: [:id], function: ->(*args) { count(*args) } },
      match_reqs: [{
        base_path: [Order, :region_id], # order
        predicate: :eq,
        related_path: [:region_id]   # employee
      }]
    }]

    @engine = ActionBlocks::DataEngine.new(
      Order,
      select_reqs: [select_reqs, summary_reqs].flatten
    )

    # puts @engine.query.to_sql

    results = @engine.query.all

    Order.all.each do |order|
      assert_equal order.region.title, results.find { |r| r['id'] == order.id }['region_title']
      assert_equal order.region.employees.count, results.find { |r| r['id'] == order.id }['count_of_region_employees']
    end
  end

  test 'summary fields can specify their own filters' do
    5.times do
      r = FactoryBot.create :region
      rs1 = FactoryBot.create :order, region: r
      rand(5).times do
        FactoryBot.create :employee, region: r, department: %w[one two three].sample
      end
    end

    select_reqs = [
      { field_name: 'id', path: [:id] },
      { field_name: 'region_title', path: %i[region title] }
    ]

    summary_reqs = [{
      type: :summary,
      root_klass: Employee,
      select_req: { field_name: :count_of_employees_for_department_two, path: [:id], function: ->(*args) { count(*args) } },
      match_reqs: [{
        base_path: [Order, :region_id], # order
        predicate: :eq,
        related_path: [:region_id]   # employee
      }],
      filter_reqs: [{
        base_path: ['two'],
        predicate: :eq,
        related_path: [:department]
      }]
    }]

    @engine = ActionBlocks::DataEngine.new(
      Order,
      select_reqs: [select_reqs, summary_reqs].flatten
    )

    # puts @engine.query.to_sql

    results = @engine.query.all

    Order.all.each do |order|
      assert_equal order.region.employees.select { |e| e.department == 'two' }.count, results.find { |r| r['id'] == order.id }['count_of_employees_for_department_two']
    end
  end

  test 'summary fields can use postgres aggregations with parameters' do
    5.times do
      r = FactoryBot.create :region
      rs1 = FactoryBot.create :order, region: r
      rand(5).times do
        FactoryBot.create :employee, region: r, department: %w[one two three].sample
      end
    end

    select_reqs = [
      { field_name: 'id', path: [:id] }
    ]

    summary_reqs = [{
                    type: :summary,
                    root_klass: Employee,
                    select_req: { field_name: :employee_departments, path: [:department], function: ->(*args) { string_agg(',', *args) } },
                    match_reqs: [{
                                 base_path: [Order, :region_id], # order
                                 predicate: :eq,
                                 related_path: [:region_id]   # employee
                                 }]
                    }]

    @engine = ActionBlocks::DataEngine.new(
      Order,
      select_reqs: [select_reqs, summary_reqs].flatten
    )

    results = @engine.query.all

    Order.all.each do |order|
      assert_equal order.region.employees.map { |r| r.department }.sort, (results.find { |r| r['id'] == order.id }['employee_departments'] || '').split(',').sort
    end
  end

end
