class TestCommand
  include ActiveModel::Model

  # In command base class
  def self.belongs_to(sym)
    define_method(sym) do
      instance_variable_get("@#{sym}")
    end
    define_method("#{sym}=") do |value|
      instance_variable_set("@#{sym}", value)
    end

    define_method("#{sym}_id") do
      instance_variable_get("@#{sym}").id
    end
    define_method("#{sym}_id=") do |value|
      instance_variable_set("@#{sym}", sym.to_s.capitalize.constantize.find(value))
    end
  end

  belongs_to :order
  belongs_to :employee

  def initialize
    super
  end
end

cmd = TestCommand.new
cmd.employee_id = 1
puts cmd.employee.inspect
