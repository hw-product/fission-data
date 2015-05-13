require 'fission-data'

module Fission
  module Data
    module Utils

      module Pricing

        # @return [Fission::Data::Models::Price]
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

        # @return [Fixnum]
        def raw_cost
          self.price.cost
        end

        # @return [Fixnum, Float]
        def cost(type=:integer)
          div = type == :integer ? 100 : 100.0
          raw_cost / div
        end

      end

    end
  end
end
