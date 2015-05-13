require 'fission-data'

module Fission
  module Data
    module Models

      # Grouping of services
      class ServiceGroup < Sequel::Model

        include Utils::Pricing

        one_to_many :products
        many_to_many :product_features
        many_to_many :services, :order => :position
        many_to_many :prices

        # Validate instance attributes
        def validate
          super
          validates_presence :name
          validates_unique :name
        end

        def before_destroy
          super
          self.remove_all_product_features
          self.remove_all_services
        end

        # @return [Array<String>]
        def route
          self.services.map(&:name)
        end

        # Association create override to allow positioning
        #
        # @param args [Hash]
        # @option args [Service] :service
        # @option args [Integer] :position
        # @return [Array<Service>]
        def add_service(args)
          db[:service_groups_services].insert(
            :service_group_id => self.id,
            :service_id => args[:service].id,
            :position => args[:position]
          )
          self.reload.services
        end

        # Generate cost of service group. If no cost has been set, the cost
        # is calculated via associated services and product features.
        #
        # @param type [Symbol] :integer or :float
        # @return [Fixnum, Float]
        def generated_cost(type=:float)
          if(raw_cost > 0)
            _cost = raw_cost
          else
            _cost = services.map{|s| s.generated_cost(:integer)}.inject(&:+).to_i +
              product_features.map{|pf| pf.generated_cost(:integer)}.inject(&:+).to_i
          end
          _cost / (type == :float ? 100.0 : 1)
        end

      end
    end
  end
end
