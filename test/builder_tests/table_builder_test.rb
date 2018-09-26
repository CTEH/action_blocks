require 'test_helper'

class TableTest < ActiveSupport::TestCase
  def setup
    ActionBlocks.unload!
    ActionBlocks.model :order do
      active_model Order
      string :num
    end
    ActionBlocks.model :order_detail do
      active_model OrderDetail
    end
  end

  test "tables created in dashboards are keyed uniquely" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders do
          dashboard :all do
            table :test
          end
        end
      end
    end
    # puts ActionBlocks.keys()
    assert ActionBlocks.find("table-construction_orders_all_test")
  end

  test "tables validate required fields" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders do
          dashboard :all do
            table :test
          end
        end
      end
    end

    assert ActionBlocks.has_error_for("TableBuilder", :columns)
    assert ActionBlocks.has_error_for("TableBuilder", :model_key)
  end


  test "dashboards must have uniquely named tables" do
    ActionBlocks.unload!
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders do
          dashboard :all do
            table :test
            table :test2
          end
        end
      end
    end
    assert !ActionBlocks.has_error_for("DashboardBuilder", :dashlets)

    ActionBlocks.unload!
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders do
          dashboard :all do
            table :test
            table :test
          end
        end
      end
    end
    assert ActionBlocks.has_error_for("DashboardBuilder", :dashlets)
  end


  test "tables know if they are without a subspace model" do
    ActionBlocks.unload!
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders do
          dashboard :all do
            table :test
          end
        end
      end
    end

    table = ActionBlocks.find("table-construction_orders_all_test")
    assert !table.subspace.model
  end

  test "tables know if they are with a subspace model" do
    ActionBlocks.unload!
    ActionBlocks.model :order do
      active_model Order
    end
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders, :order do
          dashboard :all do
            table :test
          end
        end
      end
    end

    table = ActionBlocks.find("table-construction_orders_all_test")
    assert table.subspace.model.active_model == Order

  end

  test "tables can get the subspace record give an id" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders, :order do
          dashboard :all do
            table :test
          end
        end
      end
    end

    table = ActionBlocks.find("table-construction_orders_all_test")
    assert table.subspace.model.active_model == Order
  end


  test "validates scope parameters if they are subspace or dashboard model" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders, :order do
          dashboard :order_details, :order_detail do
            table :test do
              scope -> (order_detail:, order:) {}
            end
          end
        end
      end
    end
    assert !ActionBlocks.has_error_for("TableBuilder", :scope)
  end

  test "validates current_user as a named scope parameter" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders do
          dashboard :overview do
            table :test do
              scope -> (current_user:) {}
            end
          end
        end
      end
    end
    assert !ActionBlocks.has_error_for("TableBuilder", :scope)
  end

  test "invalidates scope parameters if they are not a subspace or dashboard model" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders, :order do
          dashboard :order_details, :order_detail do
            table :test do
              scope -> (invalid_arg:) {}
            end
          end
        end
      end
    end
    assert ActionBlocks.has_error_for("TableBuilder", :scope)
  end

  test "validates columns references" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders do
          dashboard :order_details do
            table :test do
              model :order
              columns [:num]
            end
          end
        end
      end
    end
    assert !ActionBlocks.has_error_for("TableColumnBuilder", :field)
  end

  test "selection method sets keys to selection model and selection" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders, :order do
          dashboard :order_details do
            table :test do
              selection :order, :order_details
            end
          end
        end
      end
    end
    table_key = 'table-construction_orders_order_details_test'
    table = ActionBlocks.find(table_key)
    assert_equal 'model-order', table.selection_model_key
    assert_equal 'selection-order-order_details', table.selection_key
  end


  test "invalidates orphaned selection references" do
    ActionBlocks.unload!
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders, :order do
          dashboard :order_details do
            table :test do
              model :order_detail
              selection :order, :order_details
              columns [:num]
            end
          end
        end
      end
    end

    assert ActionBlocks.has_error_for("TableBuilder", :selection_model)
    assert ActionBlocks.has_error_for("TableBuilder", :selection)
  end

  test "validates selection references" do
    ActionBlocks.model :order do
      active_model Order
      selection :order_details
    end

    ActionBlocks.layout do
      workspace :construction do
        subspace :orders, :order do
          dashboard :order_details do
            table :test do
              model :order_detail
              selection :order, :order_details
              columns [:num]
            end
          end
        end
      end
    end

    assert !ActionBlocks.has_error_for("TableBuilder", :selection_model)
    assert !ActionBlocks.has_error_for("TableBuilder", :selection)
  end

  test "invalidates selection without subspace/dashboard model" do
    ActionBlocks.model :order do
      active_model Order
      selection :order_details
    end

    ActionBlocks.layout do
      workspace :construction do
        subspace :orders do
          dashboard :order_details do
            table :test do
              model :order_detail
              selection :order, :order_details
              columns [:num]
            end
          end
        end
      end
    end
    assert ActionBlocks.has_error_for("TableBuilder", :selection_model)
  end

  test "validates selection with subspace/dashboard model" do
    ActionBlocks.model :order do
      active_model Order
      selection :order_details
    end

    ActionBlocks.layout do
      workspace :construction do
        subspace :orders, :order do
          dashboard :order_details do
            table :test do
              model :order_detail
              selection :order, :order_details
              columns [:num]
            end
          end
        end
      end
    end
    assert !ActionBlocks.has_error_for("TableBuilder", :selection_model)
  end


  test "provides match_reqs" do
    ActionBlocks.model :order do
      active_model Order
      selection :order_details
    end

    ActionBlocks.model :order_detail do
      active_model OrderDetail
      references :order
    end

    ActionBlocks.layout do
      workspace :construction do
        subspace :orders, :order do
          dashboard :order_details do
            table :test do
              model :order_detail
              selection :order, :order_details
              columns [:num]
            end
          end
        end
      end
    end

    table_key = 'table-construction_orders_order_details_test'
    table = ActionBlocks.find(table_key)
    match_reqs = table.selection_match_requirements(nil)
    expected_reqs = [
      {
        :base_path=>[Order, :id],
        :predicate=>:eq,
        :related_path=>[:order_id]
      }
    ]
    assert_equal expected_reqs, match_reqs
  end

  test "provides record filter_reqs" do
    w1 = FactoryBot.create :order
    ActionBlocks.model :order do
      active_model Order
      selection :order_details
    end

    ActionBlocks.layout do
      workspace :construction do
        subspace :orders, :order do
          dashboard :order_details do
            table :test do
              model :order_detail
              selection :order, :order_details
              columns [:num]
            end
          end
        end
      end
    end

    table_key = 'table-construction_orders_order_details_test'
    table = ActionBlocks.find(table_key)
    filter_reqs = table.filter_requirements(user: nil, record: w1)
    expected_reqs = [
      {
        :base_path=>[Order, :id],
        :predicate=>:eq,
        :related_path=>[w1.id]
      }
    ]
    assert_equal expected_reqs, filter_reqs
  end

  test "validates tables have unique ids across two dashboards with same category" do
    skip
  end

  test "validates that model view for table should exist in workspace" do
    skip
  end

end
