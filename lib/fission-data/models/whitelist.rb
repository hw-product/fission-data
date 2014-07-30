require 'fission-data'

module Fission
  module Data
    module Models

      # Whitelist access
      class Whitelist < Sequel::Model
        many_to_one :creator, :class => User
      end

    end
  end
end
