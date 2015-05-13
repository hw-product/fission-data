require 'fission-data'

module Fission
  module Data
    module Models
      # Plan metadata for UI display
      class Plan < Sequel::Model

        many_to_many :prices

        def before_destroy
          super
          self.prices.map(&:destroy)
        end

        def validate
          super
          validates_presence :remote_id
          validates_unique :remote_id
        end

        def price
          if(self.prices.empty?)
            n_price = Price.create(
              :cost => 0,
              :description => "Cost for plan #{self.name}"
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
