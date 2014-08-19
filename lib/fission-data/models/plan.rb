require 'fission-data'

module Fission
  module Data
    module Models
      # Plan metadata for UI display
      class Plan < Sequel::Model

        def validate
          super
          validates_presence :remote_id
          validates_unique :remote_id
        end

      end

    end
  end
end
