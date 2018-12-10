class Command
    include ActiveModel::Model

    def self.context(sym)
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
            instance_variable_set("@#{sym}", sym.to_s.camelize.constantize.find(value))
        end

        define_method("context_id=") do |value|
            instance_variable_set("@#{sym}", sym.to_s.camelize.constantize.find(value))
        end
    end

    def execute
        raise NoMethodError
    end

    def setup
    end
end