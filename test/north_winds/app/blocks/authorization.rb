ActionBlocks.authorization User do
    grant :admin, _eq(:id, _user(:id))
end
