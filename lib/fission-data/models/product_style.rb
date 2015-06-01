require 'fission-data'

module Fission
  module Data
    module Models

      # Custom product styling
      class ProductStyle < Sequel::Model

        one_to_one :product

        def before_save
          super
          validate_presence [:style, :product_id]
          validate_unique :product_id
        end

      end

    end
  end
end
