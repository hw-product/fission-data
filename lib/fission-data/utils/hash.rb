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

module Fission
  module Data
    class Hash
      class << self

        # Copied out of carnivore. Can we share?
        def symbolize_hash(hash)
          ::Hash[*(
              hash.map do |k,v|
                if(k.is_a?(String))
                  key = k.gsub(/(?<![A-Z])([A-Z])/, '_\1').sub(/^_/, '').downcase.to_sym
                else
                  key = k
                end
                case v
                when ::Hash
                  val = symbolize_hash(v)
                when Array
                  val = v.map{|value| symbolize_hash(value)}
                else
                  val = v
                end
                [key, val]
              end.flatten(1)
          )]
        end


      end
    end
  end
end
