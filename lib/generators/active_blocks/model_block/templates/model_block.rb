ActionBlocks.model <%=variable.to_sym.inspect%> do
   <%=class_name%>
  singular_name <%=class_name.titleize.inspect%>
  plural_name <%=class_name.pluralize.titleize.inspect%>
  name_column <%=content_columns.first.to_sym.inspect%>
  sort {date_created: :desc}

  # Columns
<%content_column_details.each do |attribute| -%>
  <%=attribute.type%> <%=attribute.name.to_sym.inspect%>
<%end -%>

end
