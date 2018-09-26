require 'test_helper'

class GlobalDataTest < ActiveSupport::TestCase
  test "builders are frozen" do
    ActionBlocks.load
    builder_key  = ActionBlocks.keys().first
    builder = ActionBlocks.find(builder_key)
    # builder.freeze
    assert_raises FrozenError do
      builder.id = 'mutation'
    end
  end
end
