require 'fission-data'

module Fission
  module Data
    if(defined?(ActiveSupport::HashWithIndifferentAccess))
      class Hash < ActiveSupport::HashWithIndifferentAccess
      end
    else
      require 'hashie/extensions/deep_merge'
      require 'hashie/extensions/indifferent_access'
      class Hash < ::Hash
        include ::Hashie::Extensions::DeepMerge
        include ::Hashie::Extensions::IndifferentAccess
      end
    end
  end
end

unless(Hash.instance_methods.include?(:with_indifferent_access))
  class Hash
    def with_indifferent_access
      self
    end
  end
end

module Fission
  module Data
    class Hash
      class << self

        # base:: Hash type instance
        # keys:: Keys to walk into hash
        # Return value at and of key path
        def walk_get(base, *keys)
          keys.inject(base) do |memo, key|
            if(memo.has_key?(valid_key = key.to_s) || memo.has_key?(valid_key = key.to_sym))
              memo[valid_key]
            else
              break
            end
          end
        end

        # base:: Hash type instance
        # keys_and_val:: Keys to walk into hash ending with value to set
        # Walk into hash and set provided value
        # NOTE: If invalid type is discovered during walk, a
        # `TypeError` will be raised
        def walk_set(base, *keys_and_val)
          args = keys_and_val.dup
          val = args.pop
          last_key = args.pop
          set_point = args.inject(base) do |memo, key|
            valid_key = [key.to_sym, key.to_s].detect{|k| memo.has_key?(k)}
            if(valid_key)
              if(memo[valid_key].is_a?(::Hash))
                memo[valid_key]
              else
                raise TypeError.new("Walked to invalid type. Must be hash type for setting. Found #{memo[valid_key].class}")
              end
            else
              memo[key.to_s] = {}
              memo[key.to_s]
            end
          end
          set_point[last_key] = val
        end

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
