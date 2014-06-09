require 'sequel'
require 'multi_json'
require 'fission-data'
require 'ostruct'

module Fission
  module Data
    # SQL backed data storage
    module Sql

      # Data configuration path
      FISSION_DATA_CONFIG = '/etc/fission/sql.json'

      class << self

        # Establish connection
        #
        # @param args [Hash]
        def connect!(args=Hash.new)
          unless(Thread.current[:db])
            if(args.empty? || args[:file])
              args = connection_arguments(args[:file])
            end
            Sequel.extension :core_extensions
            Sequel.extension :pg_array
            Sequel.extension :pg_json
            Sequel.extension :pg_json_ops
            Sequel.extension :migration
            db = Thread.current[:db] = Sequel.connect(args)
            db.extension :pagination
            migrate!(db)
          end
        end

        # Migrate database
        #
        # @param db [Sequel::Database]
        def migrate!(db)
          Sequel::Migrator.run(db, File.join(File.dirname(__FILE__), 'sql', 'migrations'))
        end


        # Load connection arguments
        #
        # @param path [String] path to configuration JSON
        # @return [Hash]
        def connection_arguments(path=nil)
          path = [path, ENV['FISSION_DATA_CONFIG'] || FISSION_DATA_CONFIG].detect do |test_path|
            File.exists?(test_path.to_s)
          end
          raise 'Failed to discover valid path for database connection configuration!' unless path
          MultiJson.load(File.read(path), :symbolize_keys => true)
        end
      end

    end

    class << self
      # Establish connection
      def connect!
        Sql.connect!
      end
    end
  end
end

class Sequel::Model

  include Fission::Data::ModelInterface

  class << self

    # @return [Array<String,Symbol>] attributes of model
    def attribute_names
      columns
    end

    # @return [Array<String,Symbol>] attributes to display
    def display_attributes
      []
    end

    # @return [Array<String,Symbol>] links to display
    def display_links
      []
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

    # Filter items based on user
    #
    # @param user [Fission::Data::User]
    # @return [Sequel::Dataset]
    def restrict(user)
      if(defined?(Rails))
        Rails.logger.warn '!!! No custom user restriction provided. Returning nothing!'
      end
      []
    end

    # @return [Array] link associations
    # @todo update this data structure
    def link_associations
      {}
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

  end

  # @return [OpenStruct] instance state store
  def run_state
    @run_state ||= OpenStruct.new
  end

  # @return [Array<String,Symbol>] links to display
  def display_links(user)
    self.class.associations.keys
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

[:hook_class_methods, :timestamps, :dirty, :pg_typecast_on_load, :validation_helpers].each do |plugin_name|
  Sequel::Model.plugin plugin_name
end



module Fission
  module Data
    Dir.new(File.join(File.dirname(__FILE__), File.basename(__FILE__).sub(File.extname(__FILE__), ''))).map do |file|
      next if file.start_with?('.')
      [
        File.basename(file).sub(File.extname(file), '').split('_').map(&:capitalize).join.to_sym,
        File.join('fission-data/sql', File.basename(file).sub(File.extname(file), ''))
      ]
    end.compact.uniq.each do |klass_info|
      autoload *klass_info
      Sql.module_eval do
        autoload *klass_info
      end
    end
  end
end

Fission::Data::ModelBase = Sequel::Model
