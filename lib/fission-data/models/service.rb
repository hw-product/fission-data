require 'fission-data'

module Fission
  module Data
    module Models

      # Backend service
      class Service < Sequel::Model

        many_to_many :product_features
        many_to_many :service_groups
        many_to_many :prices
        one_to_many :service_config_items

        # Validate account attributes
        def validate
          super
          validates_presence :name
          validates_unique :name
        end

        def before_destroy
          super
          self.remove_all_product_features
          self.remove_all_service_groups
          self.prices.map(&:destroy)
          self.service_config_items.map(&:destroy)
        end

      end
    end
  end
end
