ActionBlocks.model :region do
  active_model Region
  singular_name "Region"
  plural_name "Regions"
  name_field :title

  # Columns
  string :title
  datetime :created_at
  datetime :updated_at

end
