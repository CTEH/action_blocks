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

end
