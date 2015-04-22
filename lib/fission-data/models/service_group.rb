require 'fission-data'

module Fission
  module Data
    module Models

      # Grouping of services
      class ServiceGroup < Sequel::Model

        many_to_many :product_features
        many_to_many :services, :order => :position

        # Validate instance attributes
        def validate
          super
          validates_presence :name
          validates_unique :name
        end

        def before_destroy
          super
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

      end
    end
  end
end
