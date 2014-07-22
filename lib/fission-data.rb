require 'sequel'
require 'multi_json'
require 'ostruct'

require 'fission-data/version'
require 'fission'

module Fission
  module Data

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
        Sequel::Migrator.run(db, File.join(File.dirname(__FILE__), 'fission-data', 'migrations'))
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
end


module Fission
  # Data models for Fission
  module Data

    autoload :Error, 'fission-data/errors'
    autoload :Model, 'fission-data/models'
    autoload :Models, 'fission-data/models'
    autoload :Utils, 'fission-data/utils'

  end
end
