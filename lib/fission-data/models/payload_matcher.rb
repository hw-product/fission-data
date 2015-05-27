require 'fission-data'

module Fission
  module Data
    module Models

      # Payload matcher item
      class PayloadMatcher < Sequel::Model

        many_to_one :payload_match_rule
        many_to_many :route_configs
        many_to_many :route_payload_filters
        many_to_many :service_group_payload_filters

        def before_destroy
          super
          self.remove_all_route_configs
          self.remove_all_route_payload_filters
          self.remove_all_service_group_payload_filters
        end

        def before_save
          super
          validates_presence [:account_id, :payload_match_rule_id, :value]
          validates_unique [:account_id, :payload_match_rule_id, :value]
        end

      end

    end
  end
end
