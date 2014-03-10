require 'sequel'
require 'multi_json'

module Fission
  module Data
    module Sql

      FISSION_DB_CONFIG = '/etc/fission/databse.json'

      class << self

        def connect!(args=Hash.new)
          unless(Thread.current[:db])
            if(args.empty? || args[:file])
              args = connection_arguments(args[:file])
            end
            Sequel.extension :pg_hstore
            Sequel.extension :pg_hstore_ops
            Sequel.extension :migration
            db = Thread.current[:db] = Sequel.connect(args)
            migrate!(db)
          end
        end

        def migrate!(db)
          Sequel::Migrator.run(db, File.join(File.dirname(__FILE__), 'sql', 'migrations'))
        end

        def connection_arguments(path=nil)
          path = [path, ENV['FISSION_DB_CONFIG'] || FISSION_DB_CONFIG].detect do |test_path|
            File.exists?(test_path.to_s)
          end
          raise 'Failed to discover valid path for database connection configuration!' unless path
          MultiJson.load(File.read(path), :symbolize_keys => true)
        end
      end

    end
  end
end

module Fission
  module Data
    Dir.glob(File.join(File.dirname(__FILE__), File.basename(__FILE__).sub(File.extname(__FILE__), ''), '*')).map do |file|
      [File.basename(file).sub(File.extname(file), '').split('_').map(&:capitalize).join.to_sym, file.sub(File.extname(file), '')]
    end.uniq.each do |klass_info|
      autoload *klass_info
      Sql.module_eval do
        autoload *klass_info
      end
    end
  end
end
