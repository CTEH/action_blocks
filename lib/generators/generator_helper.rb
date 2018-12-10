module ActionBlocks
  module GeneratorHelper
    protected

    def variable(cname=nil)
      cn = cname || class_name
      variableize(cn)
    end

    def collection_name(cname=nil)
      cn = cname || class_name
      collectionize(cn)
    end

    def collectionize(s)
      s.to_s.underscore.pluralize
    end

    def variableize(s)
      s.to_s.underscore.singularize
    end

    def has_many_associations?(cname=nil)
      cn = cname || class_name
      cn.constantize.reflect_on_all_associations(:has_many).map(&:name).length > 0
    end

    def has_many_associations(cname=nil)
      cn = cname || class_name
      cn.constantize.reflect_on_all_associations(:has_many).map(&:name).select {|hm| hm.downcase != 'versions'}
    end

    def has_many_association_details(cname=nil)
      cn = cname || class_name
      cn.constantize.reflect_on_all_associations(:has_many).select {|hm| hm.name.downcase != 'versions'}
    end

    def has_one_associations(cname=nil)
      cn = cname || class_name
      cn.constantize.reflect_on_all_associations(:has_one).map(&:name)
    end

    def has_one_association_details(cname=nil)
      cn = cname || class_name
      cn.constantize.reflect_on_all_associations(:has_one)
    end

    def belongs_to_associations(cname=nil)
      if respond_to?(:attributes) && attributes.present?
        attributes.select{|a| a.reference?}.map(&:name)
      else
        cn = cname || class_name
        begin
          cn.constantize.reflect_on_all_associations(:belongs_to).map(&:name)
        rescue
          []
        end
      end
    end

    def belongs_to_association_details(cname=nil)
      if respond_to?(:attributes) && attributes.present?
        attributes.select{|a| a.reference?}
      else
        cn = cname || class_name
        begin
          cn.constantize.reflect_on_all_associations(:belongs_to)
        rescue
          []
        end
      end
    end

    def content_columns(cname=nil)
      if respond_to?(:attributes) && attributes.present?
        cols = attributes.reject{|a| a.reference?}.map(&:name).map{|n| clean(n)}.compact
        cols
      else
        cn = cname || class_name
        begin
          cols = cn.constantize.content_columns.map(&:name).map {|c| clean(c)}.compact
          cols
        rescue => ex
          puts ex.message
          []
        end
      end
    end

    def content_column_details(cname=nil)
      if respond_to?(:attributes) && attributes.present?
        attributes.reject{|a| a.reference?}
      else
        cn = cname || class_name
        begin
          cn.constantize.content_columns
        rescue
          []
        end
      end
    end

    def clean(c)
      c = c.to_s
      return nil if c.in?(%w(updated_at created_at deleted deleted_at)) || c =~ /_file_size|_updated_at|_content_type/
      c.to_s.gsub('_file_name','')
    end

    def attachment_names(cname=nil)
      if respond_to?(:attributes) && attributes.present?
        attributes.select{|a| a.attachment?}.map(&:name)
      else
        cn = cname || class_name
        names = cn.constantize.content_columns.select{|a| a.name.to_s =~ /_file_name\Z/}.map{|a| a.name.to_s.gsub(/_file_name\Z/, "")}
        names
      end
    end

    def association_class_exists_with_this_name?(association_name)
      klass = Module.const_get(association_name.to_s.singularize.classify)
      return klass.is_a?(Class)
    rescue NameError
      return false
    end

    def field_content_columns
      if options.fields && options.fields.length > 0
        return options.fields & content_columns
      else
        return content_columns
      end
    end
  end
end
