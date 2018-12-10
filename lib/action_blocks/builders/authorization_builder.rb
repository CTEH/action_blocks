module ActionBlocks
    class AuthorizationBuilder < ActionBlocks::BlockType
        block_type :authorization
        sets :active_model
        builds_many :rls, :grant, 'ActionBlocks::RlsBuilder'
        includes_scheme_helpers

        def hashify(user)
            {}
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

        def hashify(user)
            {}
        end
    end
end