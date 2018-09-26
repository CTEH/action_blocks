module ActionBlocks
  class BlockType < ActionBlocks::BaseBuilder
    def is_block?
      true
    end

    def type
      raise "#{self.class} should specify its block_type."
    end
  end
end
