require 'fission-data'

module Fission
  module Data
    module Models

      # Custom routing
      class Route < Sequel::Model

        many_to_one :account
        one_to_many :route_configs, :order => :position
        many_to_many :custom_services, :order => :position
        many_to_many :services, :order => :position
        many_to_many :service_groups, :order => :position
        many_to_many :payload_matchers
        many_to_many :repositories

        # Validate instance attributes
        def validate
          super
          validates_presence :name
          validates_unique [:name, :account_id]
        end

        def before_destroy
          super
          self.remove_all_services
          self.remove_all_custom_services
          self.remove_all_service_groups
          self.route_configs.map(&:destroy)
          self.remove_all_payload_matchers
          self.remove_all_repositories
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
        # @option args [Service] :custom_service
        # @option args [Integer] :position
        # @return [Array<Service>]
        def add_custom_service(args)
          db[:custom_services_routes].insert(
            :route_id => self.id,
            :custom_service_id => args[:custom_service].id,
            :position => args[:position]
          )
          self.reload.custom_services
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

        # Provides the full route which can be a mix of Service,
        # CustomService and SeviceGroup instances.
        #
        # @return [Array<Model>]
        def route_list
          route = []
          db[:routes_services].where(:route_id => self.id).all.each do |srv_info|
            route.insert(
              srv_info[:position],
              services.detect{|s| s.id == srv_info[:service_id]}
            )
          end
          db[:custom_services_routes].where(:route_id => self.id).all.each do |srv_info|
            route.insert(
              srv_info[:position],
              custom_services.detect{|s| s.id == srv_info[:custom_service_id]}
            )
          end
          db[:routes_service_groups].where(:route_id => self.id).all.each do |grp_info|
            route.insert(
              grp_info[:position],
              service_groups.detect{|g| g.id == grp_info[:service_group_id]}
            )
          end
          route.compact
        end

        # Expands the route list out to full list of services
        #
        # @return [Array<Service|CustomService>]
        def route_services
          generated_route = []
          route_list.each do |item|
            if(item.is_a?(Service) || item.is_a?(CustomService))
              generated_route.push(item)
            elsif(item.is_a?(ServiceGroup))
              item.services.each do |srv|
                generated_route.push(srv)
              end
            end
          end
          generated_route
        end

        # Expands the route list out to full list of service names
        #
        # @return [Array<String>] routing path
        def route
          route_services.map(&:name)
        end

      end
    end
  end
end
