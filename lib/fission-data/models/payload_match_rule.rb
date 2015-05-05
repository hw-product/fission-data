require 'fission-data'

module Fission
  module Data
    module Models

      # Payload matching rule
      class PayloadMatchRule < Sequel::Model

        def validate
          super
          validates_presence :name
          validates_presence :payload_key
          validates_unique :name
          validates_unique :payload_key
        end

      end

    end
  end
end
