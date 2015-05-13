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

        # @return [Fixnum] unmodified cost (minor units)
        def raw_cost
          self.price.cost
        end

        # @return [Fixnum, Float] major units
        # @note :integer type will drop remainder
        def cost(type=:integer)
          div = type == :integer ? 100 : 100.0
          raw_cost / div
        end

        # Generate cost of item. If no cost has been set, the cost
        # can be calculated via other resources.
        #
        # @param type [Symbol] :integer or :float
        # @return [Fixnum, Float]
        # @note When :integer type is requested, this is the raw value
        #   and is minor units (will need to be divided for display)
        def generated_cost(type=:float)
          if(type == :float)
            raw_cost / 100.0
          else
            raw_cost
          end
        end

      end

    end
  end
end
