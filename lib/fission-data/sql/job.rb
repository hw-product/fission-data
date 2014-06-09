module Fission
  module Data
    module Sql

      class Job < Sequel::Model

        include Fission::Data::ModelInterface::Job

        self.add_pg_typecast_on_load_columns :payload

        many_to_one :account, :class => Sql::Account

        def validate
          super
          validates_presence [:message_id, :account_id]
        end

        class << self

          def restrict(user)
            self.where(
              :account_id => user.base_account_dataset.or(
                :account_id => user.managed_accounts_dataset.select(:id)
              ).select(:id)
            ).order(:updated_at.desc)
          end

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
