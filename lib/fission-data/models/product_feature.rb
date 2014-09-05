require 'fission-data'

module Fission
  module Data
    module Models

      # Product feature
      class ProductFeature < Sequel::Model

        many_to_one :product
        many_to_many :permissions

        # Validate account attributes
        def validate
          super
          validates_presence :name
          validates_unique [:name, :product_id]
        end

        def before_save
          super
          self.data = Sequel.pg_json(self.data)
        end

      end
    end
  end
end
