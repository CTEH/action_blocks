require 'rails/generators/base'
require 'rails/generators/resource_helpers'

module ActionBlocks
  module Generators
    class TypeGenerator < Rails::Generators::NamedBase
      attr_accessor :fields, :sub_blocks
      include ::Rails::Generators::ResourceHelpers
      include ActionBlocks::GeneratorHelper

      class_option :fields, type: :array, default: []
      class_option :builds, type: :array, default: []
      source_root File.expand_path("../templates", __FILE__)

      def view_templates
        # @struct_methods = ask("Struct Methods: (e.g. title)").split()
        # @builder_methods = ask("Builder Methods: (e.g. string_field, float_field)").split()
        @fields = options[:fields]
        @builds = options[:builds]
        template "dsl.rb", "lib/action_blocks/#{variable}_builder.rb"
        template "controller.rb", "app/controllers/#{variable}_blocks_controller.rb"
        template "type.css", "client/src/ActionBlocks/#{class_name}/#{class_name}.css"
        template "type.js", "client/src/ActionBlocks/#{class_name}/#{class_name}.js"
      end

      private

      def dsl_attr_accessors
        [variable, @builds].flatten.map {|f|f.to_sym.inspect}.join(", ")
      end
    end
  end
end
