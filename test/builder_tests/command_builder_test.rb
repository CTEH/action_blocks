require 'test_helper'

class CommandBuilderTest < ActiveSupport::TestCase
  def setup
    ActionBlocks.unload! # Remove DSL
  end

  test 'commands are stored' do
    ActionBlocks.model :order

    ActionBlocks.command :create_new_order
    
    assert ActionBlocks.find('command-create_new_order')
  end

  test 'command block can specify context' do
    ActionBlocks.model :order

    ActionBlocks.command :create_new_order do
        context :order
    end
    
    assert_not_nil ActionBlocks.find('command-create_new_order').context
  end

  test 'command block context references ActionBlocks model' do
    ActionBlocks.model :order

    ActionBlocks.command :create_new_order do
        context :order
    end
    
    assert_equal ActionBlocks.find('model-order'), ActionBlocks.find('command-create_new_order').context
  end

  test 'command block can specify form' do
    ActionBlocks.model :order

    ActionBlocks.command :create_new_order do
        context :order

        form do
        end
    end

    assert_not_nil ActionBlocks.find('command-create_new_order').form
  end

  test 'command form receives context from command' do
    ActionBlocks.model :order

    ActionBlocks.command :create_new_order do
        context :order

        form do
        end
    end

    assert_equal :order, ActionBlocks.find('command-create_new_order').form.model.id
  end


  test 'command block can specify results' do
    ActionBlocks.model :order

    ActionBlocks.command :create_new_order do
        context :order

        form do
        end

        results_in :created_order
    end

    assert_not_nil ActionBlocks.find('command-create_new_order').results_in
  end

  test 'command results can specify identifier' do
    ActionBlocks.model :order

    ActionBlocks.command :create_new_order do
        context :order

        form do
        end

        results_in :created_order do |context, command, user, event| 
            # implementation
        end
    end

    assert_equal :created_order, ActionBlocks.find('command-create_new_order').results_in.id
  end


  test 'command results can specify implementation' do
    ActionBlocks.model :order

    ActionBlocks.command :create_new_order do
        context :order

        form do
        end

        results_in :created_order do |context, command, user, event| 
            # implementation
        end
    end

    assert_not_nil ActionBlocks.find('command-create_new_order').results_in.results_method
  end

  test 'command results are mandatory' do
    ActionBlocks.model :order do
        active_model Order
    end

    ActionBlocks.command :create_new_order do
        context :order

        form do
        end

        # results_in :created_order do |context, command, user, event| 
        #     puts 'test'
        # end
    end

    assert ActionBlocks.invalid?
  end
end
