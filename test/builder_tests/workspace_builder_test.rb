require 'test_helper'

class WorkspaceTest < ActiveSupport::TestCase
  def setup
    ActionBlocks.unload!
    ActionBlocks.model :order do
      active_model Order
    end
    ActionBlocks.model :order_detail do
      active_model Order
    end
  end

  test "ActionBlocks store workspaces" do
    ActionBlocks.layout do
      workspace :construction
    end
    assert ActionBlocks.find('workspace-construction')
  end

  test "workspaces categorize subspaces" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders
        subspace :orders, :order
      end
    end

    blocks = ActionBlocks.hashify(nil)
    assert blocks['workspace-construction'][:subspace_categories]
    assert_equal 1, blocks['workspace-construction'][:subspace_categories].length
  end

  test "subspace_categories is an array" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders
        subspace :order_detail
      end
    end
    blocks = ActionBlocks.hashify(nil)
    assert_instance_of Array, blocks['workspace-construction'][:subspace_categories]
  end

  test "workspace categories have many subspaces" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders
        subspace :order_detail
      end
    end
    blocks = ActionBlocks.hashify(nil)
    categories = blocks['workspace-construction'][:subspace_categories]
    subspaces = categories.first
    assert 2, subspaces.length
  end

  test "subspace without category isn't valid" do
    ActionBlocks.layout do
      workspace :intake do
        subspace
      end
    end
    assert !ActionBlocks.valid?
  end

  test "subspace with categories is valid" do
    ActionBlocks.layout do
      workspace :intake do
        subspace :orders
      end
    end
    # puts ActionBlocks.errors
    assert ActionBlocks.valid?
  end

  test "models can be referenced by different subspaces in different workspaces" do
    ActionBlocks.layout do
      workspace :intake do
        subspace :orders, :order
      end
      workspace :construction do
        subspace :orders, :order
      end
    end
    assert ActionBlocks.valid?
  end

  test "models can't be referenced by multiple subspaces in same workspace" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders, :order
        subspace :cases, :order
      end
    end
    assert !ActionBlocks.valid?
  end

  test "models can't be referenced by muliple subspace/dashboards" do
    # Because the UI doesn't impliment it yet
    # We think that possibly for usability different reps of the same model
    # should not live in the same workspace
    ActionBlocks.layout do
      workspace :construction do
        subspace :cases
        subspace :cases, :case do
          dashboard :orders
          dashboard :orders, :order
        end
        subspace :orders
        subspace :orders, :order
      end
    end
    assert ActionBlocks.invalid?
  end

  test "subspaces categories can reference more than one model" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :scope_of_work, :order
        subspace :scope_of_work, :order_detail
      end
    end
    assert ActionBlocks.valid?
  end

  test "workspaces should know model_paths" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :scope_of_work, :order
        subspace :scope_of_work, :order_detail
      end
    end
    blocks = ActionBlocks.hashify(nil)
    assert_instance_of Hash, blocks['workspace-construction'][:model_paths]
  end

  test "workspaces should be able to know path_type" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :orders
        subspace :orders, :order do
          dashboard :order_details
          dashboard :order_details, :order_detail
        end
      end
    end
    blocks = ActionBlocks.hashify(nil)
    model_paths = blocks['workspace-construction'][:model_paths]
    assert_equal :subspace, model_paths['model-order'][:path_type]
    assert_equal :dashboard, model_paths['model-order_detail'][:path_type]
  end

  test "subspace categories cannot have more than one non-modeled subspace" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :scope_of_work
        subspace :scope_of_work
        subspace :scope_of_work, :order
      end
    end
    # pp ActionBlocks.errors
    assert ActionBlocks.invalid?
  end

  test "subspace categories can only have one non-modeled subspace" do
    ActionBlocks.layout do
      workspace :construction do
        subspace :scope_of_work
        subspace :scope_of_work, :order
      end
    end
    # pp ActionBlocks.errors_json
    assert ActionBlocks.valid?
  end

end
