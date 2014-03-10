module Fission
  module Data
    module Sql

      class Repository < BaseModel

        self.add_pg_typecast_on_load_columns :metadata

        many_to_one :account, :class => Sql::Account

        def validate
          super
          validates_presence [:name, :url]
        end

      end

    end
    Repository = Sql::Repository
  end
end
