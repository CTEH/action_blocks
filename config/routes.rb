ActionBlocks::Engine.routes.draw do
  get "action_blocks/blocks", to: "blocks#blocks"
  get "table_blocks/:block_key(/:subspace_model_id)(/:dashboard_model_id)/records", to: "table_blocks#records"
  get "form_blocks/:block_key/:record_id/record", to: "form_blocks#record"
  get "blocks", to: "blocks#index"
  get "barchart_blocks/:block_key/analytics", to: "barchart_blocks#analytics"
  get "model_blocks/:block_key/:record_id/name", to: "model_blocks#name"
  get 'attachments/:model_key/:id/:field' => "attachments#download"

end
