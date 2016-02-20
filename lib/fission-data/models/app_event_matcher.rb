require 'fission-data'

module Fission
  module Data
    module Models

      # Application Event Name Matchers
      class AppEventMatcher < Sequel::Model

        many_to_many :notifications

        # Validate app event attributes
        def validate
          super
          validates_presence :pattern
          validates_unique :pattern
        end

      end

    end
  end
end
