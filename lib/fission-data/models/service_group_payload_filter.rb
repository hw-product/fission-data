require 'fission-data'

module Fission
  module Data
    module Models

      # Filtering ruleset for payloads of service group
      class ServiceGroupPayloadFilter < Sequel::Model

        many_to_one :service_group
        many_to_many :payload_matchers

        def before_destroy
          super
          self.remove_all_payload_matchers
        end

        def before_save
          super
          validates_presence [:name, :service_group_id]
          validates_unique [:name, :service_group_id]
        end

      end

    end
  end
end
