module ActionBlocks
  class BaseBuilder
    include ActiveModel::Validations
    attr_accessor :id, :dsl_delegate

    def self.block_type(t)
      self.define_method("type") do
        return t
      end
    end

    # Dynamically create class to delegate dsl methods to
    @@delegate_classes = {}
    @@array_fields = {}

    def self.delegate_class()
      key = self.to_s
      if @@delegate_classes[key] == nil
        @@delegate_classes[key] = Class.new() do
          def initialize(obj)
            @obj = obj
          end
        end
      end
      @@delegate_classes[key]
    end

    def self.array_fields()
      key = self.to_s
      if @@array_fields[key] == nil
        @@array_fields[key] = []
      end
      @@array_fields[key]
    end

    def self.sets(field_name)
      self.send(:attr_accessor, field_name)
      self.delegate_class.define_method(field_name) do |value|
        @obj.send("#{field_name}=", value)
      end
    end

    def self.builds(field_name, klass)
      self.send(:attr_accessor, field_name)
      self.delegate_class.define_method(field_name) do |*p, &block|
        dsl_class = eval(klass.to_s)
        n = dsl_class.new()
        n.id = p.first
        n.before_build(@obj, *p)
        if n.is_block?
          ActionBlocks.store(n)
        end
        ActionBlocks.add_to_validator(n)
        n.dsl_delegate.instance_eval(&block) if block!=nil
        n.after_build(@obj, p.first)
        @obj.send("#{field_name}=", n)
      end
    end

    def self.sets_many(field_name, entry_method)
      self.array_fields().append(field_name)
      self.send(:attr_accessor, field_name)
      self.delegate_class.define_method(entry_method) do |*p, &block|
        @obj.send(field_name).append(p.first)
      end
    end

    # references :name_field,  -> (s, obj) {"field-#{obj.id}-#{s}"}
    # self.referendes block_type, [entry_method], [keyFn(f,Obj)]
    def self.references(entry_method, block_type=nil, key_proc=nil, handler: nil)
      block_type = block_type || entry_method
      self.send(:attr_accessor, "#{entry_method}_key")

      if handler
        self.delegate_class.define_method(entry_method) do |*p|
          handler.call(@obj, *p)
        end
      else
        self.delegate_class.define_method(entry_method) do |*p|
          reference_key = "#{entry_method}_key"
          if key_proc
            k = key_proc.call(p.first, @obj)
          else
            k = "#{block_type}-#{p.first}"
          end
          @obj.send("#{entry_method}_key=", k)
        end
      end

      self.define_method(entry_method) do
        k = send("#{entry_method}_key")
        if k
          return ActionBlocks.find(k)
        else
          return nil
        end
      end

      self.validate "#{entry_method}_reference_is_valid".to_sym
      self.define_method("#{entry_method}_reference_is_valid") do
        reference_key = send("#{entry_method}_key")
        if reference_key
          if !ActionBlocks.find(reference_key)
            errors.add(entry_method.to_sym, "Reference #{reference_key} doesn't match any block in store.")
          end
        end
      end
    end

    def self.includes_scheme_helpers
      self.delegate_class.define_method(:_and) do |*args|
          return [:and, *args] 
      end
  
      self.delegate_class.define_method(:_or) do |*args| 
          return [:or, *args] 
      end
  
      self.delegate_class.define_method(:_eq) do |left, right|
          return [:eq, left, right] 
      end
      
      self.delegate_class.define_method(:_user) do |field|
          return [:user, field]
      end
  
      self.delegate_class.define_method(:_not_eq) do |left, right|
          return [:not_eq, left, right]
      end  
    end

    def self.builds_many(field_name, entry_method, klass)
      self.array_fields().append(field_name)
      self.define_method("#{field_name}_hash") do
        Hash[self.send(field_name).map do |x|
          [x.id, x]
        end]
      end

      self.send(:attr_accessor, field_name)
      self.delegate_class.define_method(entry_method) do |*p, &block|
        dsl_class = eval(klass.to_s)
        n = dsl_class.new()
        n.id = p.first
        n.before_build(@obj, *p)
        if n.is_block?
          ActionBlocks.store(n)
        end
        ActionBlocks.add_to_validator(n)
        n.dsl_delegate.instance_eval(&block) if block!=nil
        n.after_build(@obj, p.first)
        if @obj.send(field_name) == nil
          @obj.send("#{field_name}=",[n])
        else
          @obj.send(field_name).append(n)
        end
      end
    end


    def initialize()
      @dsl_delegate = self.class.delegate_class.new(self)
      self.class.array_fields.each do |array_field|
        self.send("#{array_field}=", [])
      end
    end

    def key
      if(is_block?)
        "#{type}-#{@id}"
      else
        @id
      end
    end

    def ui_reference()
      key()
    end

    def evaluate(&block)
      @dsl_delegate.instance_eval(&block)
    end

    def before_build(parent, *p)
    end

    def after_build(parent, *p)
    end

    def after_load()
    end

    def is_block?
      false
    end


    # Valid the object when freeze is called so the object
    def freeze
      self.valid?
      super
    end

    # Runs all the specified validations and returns true if no errors were added
    # otherwise false. Context can optionally be supplied to define which callbacks
    # to test against (the context is defined on the validations using :on).
    def valid?(context = nil)
      unless self.frozen?
         current_context, self.validation_context = validation_context, context
         errors.clear
         @valid = run_validations!
       else
         @valid
       end
    ensure
      self.validation_context = current_context unless self.frozen?
    end

  end

end
