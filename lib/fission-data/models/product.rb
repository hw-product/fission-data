require 'fission-data'

module Fission
  module Data
    module Models

      # Product
      class Product < Sequel::Model

        one_to_many :permissions
        one_to_many :product_features

        # Validate account attributes
        def validate
          super
          validates_presence :name
          validates_unique :name
        end

      end
    end
  end
end
