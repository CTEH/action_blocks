class CreateOrder < ActionBlocks::Command

    attr_accessor(
        :employee
    )

    # Issue with putting default values here is that now the Command needs to be initialized before sending data to the client,
    # because it needs the default values. Now when the request comes back from the client (user clicks save), the class will be
    # initialized again by the Controller. This leads to the question if putting defaults here is better than putting them in
    # the form definition in the DSL or not.

    # gets called from controller
    def initialize(attributes={})
        super
        
    end

    # call from actionblock
    def setup(user:)
        @employee = @user.employee
    end

    # called from controller
    def execute(user, event)

        order = Order.new
        # do stuff
        order.order_total = order_total


    end


    # Don't trust the client app. Although we send down javascript for client side calculation of fields, 
    # there needs to be a server-side equivalent to actually calculate the value
    def order_total
        return details.reduce { |sum, detail| sum + (detail.quantity * detail.unit_price) }
    end
end