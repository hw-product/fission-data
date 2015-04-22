require 'fission-data'

module Fission
  module Data
    module Models

      # Custom routing
      class Route < Sequel::Model

        many_to_one :account
        many_to_many :services, :order => :position
        many_to_many :service_groups, :order => :position

        # Validate instance attributes
        def validate
          super
          validates_presence :name
          validates_unique :name
        end

        def before_destroy
          super
          self.remove_all_services
          self.remove_all_service_groups
        end

        # Association create override to allow positioning
        #
        # @param args [Hash]
        # @option args [Service] :service
        # @option args [Integer] :position
        # @return [Array<Service>]
        def add_service(args)
          db[:routes_services].insert(
            :route_id => self.id,
            :service_id => args[:service].id,
            :position => args[:position]
          )
          self.reload.services
        end

        # Association create override to allow positioning
        #
        # @param args [Hash]
        # @option args [ServiceGroup] :service_group
        # @option args [Integer] :position
        # @return [Array<ServiceGroup>]
        def add_service_group(args)
          db[:routes_service_groups].insert(
            :route_id => self.id,
            :service_group_id => args[:service_group].id,
            :position => args[:position]
          )
          self.reload.service_groups
        end

        # Check if account has access to services and service groups
        # defined within this route
        #
        # @return [TrueClass, FalseClass]
        def valid?
          (route_services.map(&:product_features).flatten.compact - account.product_features).empty?
        end

        # @return [Array<Service>]
        def route_services
          generated_route = []
          db[:routes_services].all.each do |srv_info|
            generated_route.insert(
              services.detect{|s| s.id == srv_info[:service_id]},
              srv_info[:position]
            )
          end
          db[:routes_service_groups].all.each do |srv_info|
            group = service_groups.detect{|grp| grp.id == srv_info[:service_group_id]}
            generated_route.insert(group, srv_info[:position])
          end
          generated_route.compact.map do |item|
            if(item.respond_to?(:services))
              item.services
            else
              item
            end
          end.flatten.compact
        end

        # @return [Array<String>] routing path
        def route
          route_services.map(&:name)
        end

      end
    end
  end
end
