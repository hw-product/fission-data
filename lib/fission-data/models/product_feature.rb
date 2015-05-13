require 'fission-data'

module Fission
  module Data
    module Models

      # Product feature
      class ProductFeature < Sequel::Model

        many_to_one :product
        many_to_many :permissions
        many_to_many :accounts
        many_to_many :services
        many_to_many :service_groups
        many_to_many :prices

        # Validate account attributes
        def validate
          super
          validates_presence :name
          validates_unique [:name, :product_id]
        end

        def before_destroy
          super
          self.remove_all_accounts
          self.remove_all_permissions
          self.remove_all_services
          self.prices.map(&:destroy)
        end

        def before_save
          super
          self.data = Sequel.pg_json(self.data)
        end

        def price
          if(self.prices.empty?)
            n_price = Price.create(
              :cost => 0,
              :description => "Cost for product feature #{self.name}"
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
