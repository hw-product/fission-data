require 'fission-data'

module Fission
  module Data
    module Models

      # Backend service
      class Service < Sequel::Model

        many_to_many :product_features
        many_to_many :service_groups
        one_to_many :service_config_items

        # Validate account attributes
        def validate
          super
          validates_presence :name
          validates_unique :name
        end

        def before_destroy
          super
          self.remove_all_service_config_items
        end

      end
    end
  end
end
