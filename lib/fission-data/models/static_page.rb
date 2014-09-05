require 'fission-data'

module Fission
  module Data
    module Models

      # Content page
      class StaticPage < Sequel::Model

        many_to_one :product

        # validate the instance
        def validate
          super
          validates_presence [:content, :title, :product_id, :path]
          validates_unique [:path, :product_id]
        end

      end

    end
  end
end
