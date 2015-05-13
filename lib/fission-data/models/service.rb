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

        def price
          if(self.prices.empty?)
            n_price = Price.create(
              :cost => 0,
              :description => "Cost for service #{self.name}"
            )
            self.add_price(n_price)
            self.reload
            n_price
          else
            if(self.prices.size > 1)
              self.prices.slice(1, self.prices.size).map(&:destroy)
              self.reload
            end
            self.prices.first
          end
        end

      end
    end
  end
end
