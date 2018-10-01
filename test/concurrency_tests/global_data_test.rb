require 'test_helper'

class GlobalDataTest < ActiveSupport::TestCase
  test "builders are frozen" do
    ActionBlocks.unload
    ActionBlocks.load(true)
    # debug ActionBlocks.keys()
    builder_key  = ActionBlocks.keys().first
    builder = ActionBlocks.find(builder_key)

    assert_raises FrozenError do
      builder.id = 'mutation'
    end
  end
end
