module ActionBlocks
  class LayoutBuilder < ActionBlocks::BlockType
    block_type :layout
    sets :title
    builds_many :workspaces, :workspace, 'ActionBlocks::WorkspaceBuilder'

    def hashify(user)
      {
        key: key,
        title: @title,
        workspace_keys: @workspaces.map(&:key),
      }
    end
  end
end
