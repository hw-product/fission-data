require 'fission-data'

module Fission
  module Data
    module Models

      # Specialized account configurations
      class AccountConfig < Sequel::Model

        many_to_one :account
        many_to_one :service
        many_to_many :route_configs

        # Validate instance attributes
        def validate
          super
          validates_presence [:name, :account_id]
          validates_unique [:name, :account_id]
        end

        def before_save
          super
          self.data ||= {}
          self.data = Sequel.pg_json(self.data)
        end

        def before_destroy
          super
          self.remove_all_route_configs
        end

        # Association create override to allow positioning
        #
        # @param args [Hash]
        # @option args [RouteConfig] :route_config
        # @option args [Integer] :position
        # @return [Array<RouteConfig>]
        def add_route_config(args)
          db[:account_configs_route_configs].insert(
            :route_config_id => args[:route_config].id,
            :account_config_id => self.id,
            :position => args[:position]
          )
          self.reload.route_configs
        end

        # @return [Fission::Utils::Smash]
        def data
          unless(self.values[:data].is_a?(Smash))
            self.values[:data] = (self.values[:data] || {}).to_smash
          end
          self.values[:data]
        end

      end
    end
  end
end
