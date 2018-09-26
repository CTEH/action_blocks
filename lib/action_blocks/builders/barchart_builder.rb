module ActionBlocks

  class BarchartBuilder < ActionBlocks::BlockType
    block_type :barchart
    sets :title
    sets :scope
    sets :calculate
    builds :group, 'ActionBlocks::BarchartGroupBuilder'
    builds :subgroup, 'ActionBlocks::BarchartGroupBuilder'

    def before_build(parent, *args)
      @id = "#{parent.id}_#{args.first}"
      @title = id.to_s.titleize
      @calculate = :count
    end

    def hashify(user)
      {
        title: @title,
        key: key,
        type: type,
        group: @group.try(:hashify, user),
        subgroup: @subgroup.try(:hashify, user)
      }
    end
  end

  class BarchartGroupBuilder < ActionBlocks::BaseBuilder
    sets :column
    sets :order_by
    sets :grouping_by

    def before_build(parent, *args)
      @column = args[0]
      @order_by = :ascending
      @grouping_by = :equal_values
    end

    def hashify(user)
      {
        column: @column,
        order_by: @order_by,
        grouping_by: @grouping_by
      }
    end
  end

end
