require 'fission-data'

# TODO: attempt mash and hashie usage, fall back to self
unless(Hash.instance_methods.include?(:with_indifferent_access))
  class Hash
    def with_indifferent_access
      self
    end
  end
end

module Fission
  module Data
    if(defined?(ActiveSupport::HashWithIndifferentAccess))
      class Hash < ActiveSupport::HashWithIndifferentAccess
      end
    else
      # TODO: mash/hashie
      class Hash < ::Hash
      end
    end
  end
end
