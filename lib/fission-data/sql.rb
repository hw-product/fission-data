require 'sequel'
require 'multi_json'

module Fission
  module Data
    module Sql

      FISSION_SQL_CONFIG = '/etc/fission/sql.json'

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
          path = [path, ENV['FISSION_SQL_CONFIG'] || FISSION_SQL_CONFIG].detect do |test_path|
            File.exists?(test_path.to_s)
          end
          raise 'Failed to discover valid path for database connection configuration!' unless path
          MultiJson.load(File.read(path), :symbolize_keys => true)
        end
      end

    end

    class << self
      def connect!
        Sql.connect!
      end
    end
  end
end

class Sequel::Model

  include ModelInterface

  class << self

    def attribute_names
      columns
    end

    def display_attributes
      []
    end

    def display_links
      []
    end

    def find(*args)
      if(args.first.is_a?(String) || args.first.is_a?(Numeric))
        super(:id => args.first)
      else
        super
      end
    end

    def restrict(user)
      if(defined?(Rails))
        Rails.logger.warn '!!! No custom user restriction provided. Returning nothing!'
      end
      []
    end

    # TODO: update this data structure
    def link_associations
      {}
    end

    def method_missing(method, *args, &block)
      if(method.to_s.start_with?('find_by'))
        key = method.to_s.sub('find_by_', '').to_sym
        self.find(key => args.first)
      else
        super
      end
    end

    def sorter!(set)
    end
  end

  def display_links(user)
    self.class.associations.keys
  end

end

[:timestamps, :dirty, :pg_typecast_on_load, :validation_helpers].each do |plugin_name|
  Sequel::Model.plugin plugin_name
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
