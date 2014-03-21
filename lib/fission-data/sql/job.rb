module Fission
  module Data
    module Sql

      class Job < Sequel::Model

        self.add_pg_typecast_on_load_columns :payload

        many_to_one :account, :class => Sql::Account

        def validate
          super
          validates_presence [:message_id, :account_id]
        end

        # Compat method
        def last_update
          self.updated_at.to_i
        end

      end

    end
    Job = Sql::Job
  end
end
