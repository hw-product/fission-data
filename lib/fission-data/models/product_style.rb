require 'fission-data'

module Fission
  module Data
    module Models

      # Custom product styling
      class ProductStyle < Sequel::Model

        many_to_one :product

        def before_save
          super
          validates_presence [:style, :product_id]
          validates_unique :product_id
          self.style = Sequel.pg_json(self.style)
        end

        # @return [Fission::Utils::Smash]
        def style
          unless(self.values[:style].is_a?(Smash))
            self.values[:style] = (self.values[:style] || {}).to_smash
          end
          self.values[:style]
        end

      end

    end
  end
end
