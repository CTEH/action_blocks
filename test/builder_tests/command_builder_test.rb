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


  # test 'command block can specify results' do
  #   ActionBlocks.model :order

  #   ActionBlocks.command :create_new_order do
  #       context :order

  #       form do
  #       end

  #       results_in :created_order
  #   end

  #   assert_not_nil ActionBlocks.find('command-create_new_order').results_in
  # end

  # test 'command results can specify identifier' do
  #   ActionBlocks.model :order

  #   ActionBlocks.command :create_new_order do
  #       context :order

  #       form do
  #       end

  #       results_in :created_order do |context, command, user, event| 
  #           # implementation
  #       end
  #   end

  #   assert_equal :created_order, ActionBlocks.find('command-create_new_order').results_in.id
  # end


  # test 'command results can specify implementation' do
  #   ActionBlocks.model :order

  #   ActionBlocks.command :create_new_order do
  #       context :order

  #       form do
  #       end

  #       results_in :created_order do |context, command, user, event| 
  #           # implementation
  #       end
  #   end

  #   assert_not_nil ActionBlocks.find('command-create_new_order').results_in.results_method
  # end

  # test 'command results are mandatory' do
  #   ActionBlocks.model :order do
  #       active_model Order
  #   end

  #   ActionBlocks.command :create_new_order do
  #       context :order

  #       form do
  #       end

  #       # results_in :created_order do |context, command, user, event| 
  #       #     puts 'test'
  #       # end
  #   end

  #   assert ActionBlocks.invalid?
  # end

  test 'command can specify an implementation' do
    ActionBlocks.model :order

    ActionBlocks.command :create_new_order do
      context :order

      form do
      end

      implemented_by CreateOrder
    end

    assert_not_nil ActionBlocks.find('command-create_new_order').implemented_by
  end

  test 'command implementation is mandatory' do
    ActionBlocks.model :order

    ActionBlocks.command :create_new_order do
      context :order

      form do
      end

      # implemented_by CreateOrder
    end

    assert ActionBlocks.invalid?
  end

  # TODO: split, currently placeholder for the specs
  test 'all required form specifications can be specified' do

    ActionBlocks.model :order

    ActionBlocks.command :create_new_order do
      context :customer # should be optional

      implemented_by CreateOrder

      form do
        reference :customer do
          value -> (context, params) { context }
          behavior :read_only
        end

        lookup :customer, :last_name
        lookup :customer, :city
        lookup :customer, :phone

        reference :employee do
          # specified as def rate_sheet_default in command implementation class
          # default -> (context, params) { context.vendor.default_rate_sheet }

          # specified as def rate_sheet_options in command implementation class
          options [:vendor], -> (context, params) { context.vendor.rate_sheets.where(status: 'active') }
          behavior do
            default :read_only
            editable "return command.change_items.length == 0"
          end
        end

        details :order_details do
          behavior :read_only do
            editable "command.rate_sheet != null"
          end

          reference :product do
            param :rate_sheet, "command.rate_sheet" # need a solution for initial population of options based on these params
            # specified as def change_items_rate_options
            options -> (context, params) { RateSheet.find(params.rate_sheet).rates }
            display [:code, :description]
          end

          reference :product_variation do
            param :product, "command.product"
            options -> (context, params) { ProductVariation.where(product: params.product) }
            display [:description, :color, :size]
          end

          decimal :quantity
          lookup :product, :list_price
          calculate :unit_price, "(detail) => detail.product.list_price" # won't be part of the data sent back on submit
        end

        calculate :order_total, "(command) => command.order_details.reduce( (sum, x) => {sum + (x.rate.unit_price * x.qty)})"
      end
    end
  end
end
