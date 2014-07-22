require 'fission-data'

module Fission
  module Data
    # Custom error class
    class Error < StandardError

      class PermissionDeniedError < Error
      end

    end

  end
end
