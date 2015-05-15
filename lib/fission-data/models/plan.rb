require 'fission-data'

module Fission
  module Data
    module Models
      # Plan metadata for UI display
      class Plan < Sequel::Model

        include Utils::Pricing

        many_to_many :prices
        many_to_many :products

        def before_destroy
          super
          self.remove_all_products
          self.prices.map(&:destroy)
        end

        def validate
          super
          validates_presence :name
          validates_unique :name
        end

        # Generate cost of plan. If no cost has been set, the cost
        # is calculated via associated service groups.
        #
        # @param type [Symbol] :integer or :float
        # @return [Fixnum, Float]
        def generated_cost(type=:float)
          if(raw_cost > 0)
            _cost = raw_cost
          else
            _cost = service_groups.map{|sg| sg.generated_cost(:integer)}.inject(&:+).to_i
          end
          _cost / (type == :float ? 100.0 : 1)
        end

      end

    end
  end
end
