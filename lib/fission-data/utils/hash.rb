require 'fission-data'

# Compatibility class alias
class Fission::Data::Hash < Smash; end

unless(Hash.instance_methods.include?(:with_indifferent_access))
  class Hash
    # Rails compatibility helper
    def with_indifferent_access
      self.to_smash
    end
  end
end

module Fission
  module Data
    class Hash
      class << self

        # Get value
        #
        # @param base [Smash]
        # @param keys [Object] argument list
        # @return [Object]
        def walk_get(base, *keys)
          base.get(*keys)
        end

        # Set value
        #
        # @param base [Smash]
        # @param keys_and_val [Object] argument list
        # @return [Object]
        def walk_set(base, *keys_and_val)
          base.set(*keys_and_val)
        end

      end
    end
  end
end
