require 'fission-data'

module Fission
  module Data
    module Models

      # Payload matcher item
      class PayloadMatcher < Sequel::Model

        many_to_one :payload_match_rule
        many_to_many :route_configs

        def before_destroy
          super
          self.remove_all_route_configs
        end

        def before_save
          super
          validates_presence :value
        end

      end

    end
  end
end
