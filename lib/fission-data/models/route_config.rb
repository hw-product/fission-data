require 'fission-data'

module Fission
  module Data
    module Models

      # Configuration for routing
      class RouteConfig < Sequel::Model

        many_to_one :route
        many_to_many :account_configs, :order => :position
        many_to_many :payload_matchers

        def before_save
          super
          validates_presence :name
          validates_unique [:name, :route_id]
        end

        def before_destroy
          super
          self.remove_all_account_configs
          self.remove_all_payload_matchers
        end

        # Association create override to allow positioning
        #
        # @param args [Hash]
        # @option args [AccountConfig] :account_config
        # @option args [Integer] :position
        # @return [Array<AccountConfig>]
        def add_account_config(args)
          db[:account_configs_route_configs].insert(
            :route_config_id => self.id,
            :account_config_id => args[:account_config].id,
            :position => args[:position]
          )
          self.reload.account_configs
        end

      end
    end
  end
end
