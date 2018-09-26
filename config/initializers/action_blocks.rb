def database_exists?
    ActiveRecord::Base.connection
rescue ActiveRecord::NoDatabaseError
    false
else
    true
end

ActionBlocks.initial_load if database_exists?
