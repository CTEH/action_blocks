module ActionBlocks
  class <%=class_name%>Builder < ActionBlocks::BlockType
    block_type :<%=variable%>
<%@fields.each do |f| -%>
    sets :<%=variableize(f)%>
<%end -%>
<%@builds.each do |b| -%>
    # builds :<%=variableize(b)%>, 'ActionBlocks::<%=variableize(b).camelize%>Builder'
    # builds_many :<%=variableize(b).pluralize%>, :<%=variableize(b)%>, 'ActionBlocks::<%=variableize(b).camelize%>Builder'
<%end -%>

    # to json
    def hashify(user)
      {
<%@fields.each do |f| -%>
        <%=variableize(f)%>: @<%=variable%>.<%=variableize(f)%>,
<%end -%>
<%@builds.each do |f| -%>
        <%=variableize(f)%>: @<%=variableize(f)%>,
<%end -%>
        key: key,
        type: type,
      }
    end

  end
<%@builds.each do |b| -%>
  class <%=class_name%>Builder < ActionBlocks::BaseBuilder

    def hashify(user)
        key: key,
        type: type,
      }
    end
  end
<%end -%>

end
