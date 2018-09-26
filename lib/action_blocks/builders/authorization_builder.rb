module ActionBlocks
    class AuthorizationBuilder < ActionBlocks::BlockType
        block_type :authorization
        sets :active_model
        builds_many :rls, :grant, 'ActionBlocks::RlsBuilder'

        AuthorizationBuilder.delegate_class.define_method(:_and) do |*args|
            return [:and, *args] 
        end

        AuthorizationBuilder.delegate_class.define_method(:_or) do |*args| 
            return [:or, *args] 
        end

        AuthorizationBuilder.delegate_class.define_method(:_eq) do |left, right|
            return [:eq, left, right] 
        end
        
        AuthorizationBuilder.delegate_class.define_method(:_user) do |field|
            return [:user, field]
        end

        AuthorizationBuilder.delegate_class.define_method(:_not_eq) do |left, right|
            return [:not_eq, left, right]
        end
    end

    class RlsBuilder < ActionBlocks::BlockType
        block_type :rls
        sets :role
        sets :filter
        sets :scheme # Lisp like data structure sp

        def before_build(parent, role, scheme=nil)
            @role = role
            @id = "#{parent.id}-#{role}"
            @scheme = scheme
        end
    end
end