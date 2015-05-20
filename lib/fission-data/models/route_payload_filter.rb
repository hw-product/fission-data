require 'fission-data'

module Fission
  module Data
    module Models

      # Filtering ruleset for payloads
      class RoutePayloadFilter < Sequel::Model

        many_to_one :route
        many_to_many :payload_matchers

        def before_destroy
          super
          self.remove_all_payload_matchers
        end

        def before_save
          super
          validates_presence [:name, :route_id]
          validates_unique [:name, :route_id]
        end

      end

    end
  end
end
