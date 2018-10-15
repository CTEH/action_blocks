# ActionBlocks.method delegates calls to here

module ActionBlocks
  class Store

    def initialize
      super
      @block_store = {};
      @validation_store = [];
    end

    # ActionBlocks.layout
    def layout(*p, &block)
      l = ActionBlocks::LayoutBuilder.new()
      l.id = 'main'
      l.before_build(nil, *p)
      store(l)
      add_to_validator(l)
      l.evaluate(&block) if block
      l.after_build(nil, *p)
    end

    def form(*p, &block)
      rs = ActionBlocks::FormBuilder.new()
      rs.id = p.first
      rs.before_build(nil, *p)
      store(rs)
      add_to_validator(rs)
      rs.evaluate(&block) if block
      rs.after_build(nil, *p)
    end

    def authorization(*p, &block)
      rs = ActionBlocks::AuthorizationBuilder.new()
      rs.active_model = p.first
      rs.id = rs.active_model.to_s.underscore
      rs.before_build(nil, *p)
      store(rs)
      add_to_validator(rs)
      rs.evaluate(&block) if block
      rs.after_build(nil, *p)
    end

    def model(*p, &block)
      m = ActionBlocks::ModelBuilder.new()
      m.id = p.first
      m.before_build(nil, *p)
      store(m)
      add_to_validator(m)
      m.evaluate(&block) if block
      m.after_build(nil, *p)
    end

    def command(*p, &block)
      m = ActionBlocks::CommandBuilder.new()
      m.id = p.first
      m.before_build(nil, *p)
      store(m)
      add_to_validator(m)
      m.evaluate(&block) if block
      m.after_build(nil, *p)
    end


    def valid?
      @validation_store.all? { |builder| builder.valid? }
    end

    def invalid?
      !valid?
    end

    # def errors
    #   results = []
    #   @validation_store.each do |b|
    #     results << b.errors if b.invalid?
    #   end
    #   results
    # end

    def errors
      results = []
      @validation_store.each do |b|
        results << {
          builder: b.class.to_s.sub("ActionBlocks::",""),
          key: b.key,
          fields: b.errors.keys,
          messages: b.errors.map {|k,v| [k,v]}
        } if b.invalid?
      end
      results
    end

    def has_error_for(block_type, field_name)
      type_errors = errors.select { |e|
        e[:builder] == block_type &&
        e[:fields].include?(field_name)
      }
      if type_errors == []
        return false
      else
        return type_errors
      end
    end

    def has_error(substring)
      all_errors = errors.map {|e| e.messages}.map {|h| h.values}.flatten.join("\n")
      all_errors[substring]
    end

    def unload!
      # If classes were dynamically created.
      # We would remove const here (JRH)
      @block_store = {};
      @validation_store = [];
    end

    def keys()
      @block_store.keys
    end

    def store(block)
      @block_store[block.key] = block
    end

    def add_to_validator(builder)
      @validation_store << builder
    end

    def find(block_key)
      @block_store[block_key]
    end

    def get(params)
      @block_store[params[:block_key]].get(params)
    end

    def hashify(user)
      result = {}
      @block_store.each do |key, block|
        result[block.key] = block.hashify(user)
        result[block.key][:key] = block.key
      end
      result[:errors] = errors
      result
    end

    def freeze_builders
      @block_store.values.each do |v|
        v.freeze
        puts "#Freezing #{v.key}"
      end
    end

    def after_load
      @validation_store.each do |v|
        v.after_load
      end
    end

  end
end
