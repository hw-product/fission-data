require 'fission-data'

# All plugins we want loaded by default
FISSION_SEQUEL_PLUGINS = [
  :hook_class_methods,
  :timestamps,
  :dirty,
  :pg_typecast_on_load,
  :validation_helpers
]

FISSION_SEQUEL_PLUGINS.each do |plugin_name|
  Sequel::Model.plugin plugin_name
end

module Fission
  module Data
    module SequelExtension

      module InstanceMethods

        # Helper proxy for converting smashes
        #
        # @param values [Hash]
        def fission_extension_initialize_set(values={})
          smashed = Hash.new.tap do |converted|
            values.each do |k,v|
              converted[k] = v.respond_to?(:to_smash) ? v.to_smash : v
            end
          end
          unfission_extension_initialize_set(smashed)
        end

        # @return [String]
        def to_s
          id
        end

        # @return [OpenStruct] instance state store
        def run_state
          @run_state ||= OpenStruct.new
        end

        # @return [String] generate key from name and source
        def name_source
          if(respond_to?(:name) && respond_to?(:source))
            "#{name}_#{source.name}"
          end
        end

        # Add support for add attribute methods
        # @todo Better `#add_` mapping and include removal
        def method_missing(method, *args, &block)
          if(method.to_s.start_with?('add_') && method.to_s.end_with?('s'))
            non_plural = method.to_s.sub(/s$/, '').to_sym
            if(respond_to?(non_plural))
              unless(self.send(method.to_s.sub('add_', '')).include?(args.first))
                self.send(non_plural, *args, &block)
              end
            else
              super
            end
          else
            super
          end
        end

        # @return [Numeric, String] model id
        def key
          id
        end

      end

      module ClassMethods

        # @return [Array<String,Symbol>] attributes of model
        def attribute_names
          columns
        end

        # Overide to allow direct find without `:id`
        #
        # @param args [Object] argument list
        # @return [Object]
        def find(*args)
          if(args.first.is_a?(String) || args.first.is_a?(Numeric))
            super(:id => args.first)
          else
            super
          end
        end

        # Allow find by attribute name searching
        def method_missing(method, *args, &block)
          if(method.to_s.start_with?('find_by'))
            key = method.to_s.sub('find_by_', '').to_sym
            self.filter(key => args.first.to_s).first
          else
            super
          end
        end

        # Generate a source key
        #
        # @param args [Object] argument list
        # @return [String] argument list stringed and joined
        def source_key(*args)
          args.compact.map(&:to_s).join('_')
        end

      end

      def self.included(klass)
        klass.class_eval do

          include Fission::Data::SequelExtension::InstanceMethods
          extend Fission::Data::SequelExtension::ClassMethods

          alias_method :unfission_extension_initialize_set, :initialize_set
          alias_method :initialize_set, :fission_extension_initialize_set
        end
      end

    end
  end
end

# Infect sequel
Sequel::Model.send(:include, Fission::Data::SequelExtension)

module Fission
  module Data
    module Models

      autoload :Account, 'fission-data/models/account'
      autoload :AccountConfig, 'fission-data/models/account_config'
      autoload :CustomerPayment, 'fission-data/models/customer_payment'
      autoload :CustomService, 'fission-data/models/custom_service'
      autoload :Event, 'fission-data/models/event'
      autoload :Identity, 'fission-data/models/identity'
      autoload :Job, 'fission-data/models/job'
      autoload :LogEntry, 'fission-data/models/log_entry'
      autoload :Log, 'fission-data/models/log'
      autoload :PayloadMatcher, 'fission-data/models/payload_matcher'
      autoload :PayloadMatchRule, 'fission-data/models/payload_match_rule'
      autoload :Permission, 'fission-data/models/permission'
      autoload :Plan, 'fission-data/models/plan'
      autoload :Price, 'fission-data/models/price'
      autoload :Product, 'fission-data/models/product'
      autoload :ProductFeature, 'fission-data/models/product_feature'
      autoload :ProductStyle, 'fission-data/models/product_style'
      autoload :Repository, 'fission-data/models/repository'
      autoload :Route, 'fission-data/models/route'
      autoload :RouteConfig, 'fission-data/models/route_config'
      autoload :RoutePayloadFilter, 'fission-data/models/route_payload_filter'
      autoload :Service, 'fission-data/models/service'
      autoload :ServiceConfigItem, 'fission-data/models/service_config_item'
      autoload :ServiceGroup, 'fission-data/models/service_group'
      autoload :ServiceGroupPayloadFilter, 'fission-data/models/service_group_payload_filter'
      autoload :Session, 'fission-data/models/session'
      autoload :Source, 'fission-data/models/source'
      autoload :StaticPage, 'fission-data/models/static_page'
      autoload :Tag, 'fission-data/models/tag'
      autoload :Token, 'fission-data/models/token'
      autoload :User, 'fission-data/models/user'
      autoload :Whitelist, 'fission-data/models/whitelist'

    end
  end
end

if(defined?(Rails))
  require 'fission-data/rails-init'
end
