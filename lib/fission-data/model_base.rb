require 'fission-data'
require 'securerandom'
require 'ostruct'
require 'risky'
require 'fission-data/utils/hash'

module Fission
  module Data

    class ModelBase < Risky

      FISSION_RIAK_CONFIG = '/etc/fission/riak.json'

      # Execute these things on inclusion

      class << self

        def connect!(args={})
          if(args.empty? || args[:file])
            args = connection_arguments(args[:file])
          end
          Risky.riak = Riak::Client.new(args)
        end

        def connection_arguments(path=nil)
          path = [path, ENV['FISSION_RIAK_CONFIG'] || FISSION_RIAK_CONFIG].detect do |test_path|
            File.exists?(test_path.to_s)
          end
          raise 'Failed to discover valid path for riak connection configuration!' unless path
          Fission::Data::Hash.symbolize_hash(
            MultiJson.load(File.read(path))
          )
        end

        def inherited(klass)
          klass.class_eval do

            # Active library helper inclusion
            if(defined?(ActiveModel))
              include ActiveModel::Validations
              include ActiveModel::Conversion
              extend ActiveModel::Naming
              include Utils::NamingCompat
              include Utils::ValidationCompat
            end

            # Risky helper inclusion
            include Risky::Indexes
            include Risky::Timestamps
            include Risky::ListKeys

            class << self

              # Override create method to auto generate key
              def create(values={})
                key = SecureRandom.uuid
                super(key, values)
              end

              # Support method for compat
              def table_name
                self.name.split('::').last.underscore.pluralize
              end

              # Return list of attribute names
              def attribute_names
                values.keys
              end

              # Return list of attributes to be displayed
              def display_attributes
                []
              end

              # Display links (can be `nil` or `false` to turn off,
              # `true` to enable
              # NOTE: Link display require defined routes
              def display_links
                true
              end

              # Return instance with given key
              def find(key)
                self[key]
              end

              # query:: solr search
              # Raw search
              def search(query)
                self.riak.search(bucket.name, query)
              end

              # user:: User instance
              # Return limited set accessible to user
              def restrict(user)
                if(defined?(Rails))
                  Rails.logger.warn '!!! No custom user restriction provided. Returning nothing!'
                end
                []
              end

              # Return assocations of class
              def associations
                unless(@associations)
                  @associations = {}.with_indifferent_access
                end
                @associations
              end

              # Provide find_by_* compatible methods
              def method_missing(method, *args)
                if(method.to_s.start_with?('find_by'))
                  self.send(method.to_s.sub('find_', ''), *args)
                else
                  super
                end
              end

              alias_method :risky_links, :links

              def links(name, klass=nil, args={})
                associations[name] = {
                  :class => klass,
                  :style => :many,
                  :reverse => args[:to],
                  :dependent => args[:dependent]
                }
                risky_links(name)
                if(klass)
                  class_eval do
                    alias_method "risky_#{name}".to_sym,  name.to_sym
                    define_method(name) do
                      send("risky_#{name}".to_sym).map do |k|
                        klass[k]
                      end
                    end
                  end
                end
              end

              alias_method :risky_link, :link

              def link(name, klass=nil, args={})
                associations[name] = {
                  :class => klass,
                  :style => :one,
                  :reverse => args[:to],
                  :dependent => args[:dependent]
                }
                risky_link(name)
                if(klass)
                  class_eval do
                    alias_method "risky_#{name}".to_sym, name.to_sym
                    define_method(name) do
                      klass[send("risky_#{name}".to_sym)]
                    end
                  end
                end
              end

              # args:: Strings
              # Returns key
              def source_key(*args)
                args.compact.join('_')
              end

            end
          end
        end
      end

      # customizations and overrides

      # Ephemeral state
      attr_reader :run_state, :dirty_base

      def initialize(*args)
        @dirty_base = {}
        @run_state = OpenStruct.new
        key = args.detect{|item| !item.is_a?(::Hash) } || SecureRandom.uuid
        values = args.detect{|item| item.is_a?(::Hash) } || {}
        super(key, values)
        init_dirty
      end

      # Initialize dirty data structure
      def init_dirty
        dirty_base[:values] = @values.dup
        dirty_base[:links] = @riak_object ? @riak_object.links.dup : Set.new
        self
      end

      # attribute:: Optional attribute name for explicity check
      # Check if attribute data is dirty
      def dirty?(attribute=nil)
        if(attribute)
          dirty_values.include?(attribute.to_sym)
        else
          !!dirty.values.detect do |val|
            !val.empty?
          end
        end
      end

      # Return hash of dirty attribute keys and links diff
      def dirty
        {
          :values => dirty_values,
          :links => dirty_links
        }
      end

      # Return names of dirty attributes
      def dirty_values
        values.find_all{|k,v| dirty_base[:values][k] != v }.map(&:first).map(&:to_sym)
      end

      # Return list of dirty links
      def dirty_links
        res = dirty_base[:links].difference(@riak_object.links)
        if(res.empty?)
          @riak_object.links.difference(dirty_base[:links])
        else
          res
        end
      end

      # Init dirty data structure after loading
      def after_load
        super
        init_dirty
      end

      #  Automatic link updates after save
      def after_save
        super
        dirty_links.each do |riak_link|
          attribute = riak_link.tag.to_s
          next if attribute == 'up' # new instance link
          info = self.class.associations[attribute]
          if(info && info[:reverse])
            action = riak_object.links.include?(riak_link) ? :add : :remove
            instance = info[:class][riak_link.key]
            if(instance)
              remote_association = info[:class].associations[info[:reverse]]
              if(remote_association[:style] == :many)
                remote_args = ["#{action}_#{info[:reverse]}", self]
              else
                remote_args = ["#{info[:reverse]}=", action == :add ? self : nil]
              end
              instance.send(*remote_args)
              instance.save
            end
          else
            if(defined?(Rails))
              Rails.logger.warn "Failed to locate assocation for given link: #{attribute}. Current assocation structure: #{self.class.associations}"
            end
          end
        end
        init_dirty
      end

      # Automatic cleanup of links on remote models
      def after_delete
        super
        self.class.associations.each do |attribute, info|
          if(info[:reverse])
            remote_association = info[:class].associations[info[:reverse]]
            if(remote_association[:dependent])
              remote_args = [:delete]
            elsif(remote_association[:style] == :many)
              remote_args = ["remove_#{info[:reverse]}", self]
            else
              remote_args = ["#{info[:reverse]}=", nil]
            end
            case info[:style]
            when :many
              self.send(attribute).each do |instance|
                if(instance)
                  instance.send(*remote_args)
                  instance.save unless remote_args.first == :delete
                end
              end
            when :one
              instance = self.send(attribute)
              if(instance)
                instance.send(*remote_args)
                instance.save unless remote_args.first == :delete
              end
            end
          end
        end
      end

      # Override values to provide indifferent access
      def values
        super.with_indifferent_access
      end

      # Hash setting for values
      def []=(k,v)
        values[k] = v
      end

      # Hash access to values
      def [](k)
        values[k]
      end

      # If instance is persisted
      def persisted?
        true
      end

      # ID of instance
      def id
        begin
          super
        rescue TypeError
          raise unless new?
          ''
        end
      end

      # Attempt nice string output
      def to_s
        respond_to?(name) && name ? name : id
      end

      # user:: Fission::Data::User instance
      # Return links allowed viewable to given user
      def display_links(user)
        self.class.associations.keys
      end

    end

  end
end
