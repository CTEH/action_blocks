ActionBlocks.model <%=variable.to_sym.inspect%> do
  active_model <%=class_name%>
  singular_name <%=class_name.titleize.inspect%>
  plural_name <%=class_name.pluralize.titleize.inspect%>
  name_field <%=content_columns.first.to_sym.inspect%>

  # Columns
<%content_column_details.each do |attribute| -%>
  <%=attribute.type%> <%=attribute.name.to_sym.inspect%>
<%end -%>

end
