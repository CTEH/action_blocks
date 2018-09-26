module ActionBlocks
  module SummaryFieldAggregationFunctions
    def count
      # mk = @parent_reference.related_model_key.clone
      # mk["model-"]=''
      # field_key = "field-#{mk}-#{id}"
      # field_builder = ActionBlocks.find(field_key)

      return {
        path: [:id],
        function: ->(*args) { count(*args) }\
      }
    end

    def concat(field, delimiter)
      mk = @parent_reference.related_model_key.clone
      mk["model-"]=''
      field_key = "field-#{mk}-#{field}"
      puts field_key
      field_builder = ActionBlocks.find(field_key)

      return {
        path: field_builder.select_requirements[:path],
        function: ->(*args) { string_agg(delimiter, *args) }
      }
    end

    def every(field, predicate, value)
      mk = @parent_reference.related_model_key.clone
      mk["model-"]=''
      field_key = "field-#{mk}-#{field}"
      puts field_key
      field_builder = ActionBlocks.find(field_key)

      return {
      path: field_builder.select_requirements[:path],
      function: ->(*args) { every(predicate, value, *args) }
      }
    end
  end
end