require 'rails/generators/base'
require 'rails/generators/resource_helpers'
require_relative '../../generator_helper'

module ActionBlocks
  module Generators
    class ModelBlockGenerator < Rails::Generators::NamedBase
      include ::Rails::Generators::ResourceHelpers
      include ActionBlocks::GeneratorHelper

      source_root File.expand_path("../templates", __FILE__)

      def view_templates
        template "model_block.rb", "app/blocks/#{variable}_model_block.rb"
      end
    end
  end
end
