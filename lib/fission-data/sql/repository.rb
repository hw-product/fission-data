module Fission
  module Data
    module Sql

      class Repository < Sequel::Model

        include Fission::Data::ModelInterface::Repository

        self.add_pg_typecast_on_load_columns :metadata

        many_to_one :account, :class => Sql::Account

        def validate
          super
          validates_presence [:name, :url]
        end

        class << self

          def lookup(name, source)
            source = Source.find_by_name(source)
            if(source)
              self.where(
                :account_id => source.accounts_dataset.select(:id)
              )
            end
          end

          def restrict(user)
            self.where(
              :account_id => user.base_account_dataset.or(
                user.managed_accounts.dataset
              ).select(:id)
            ).order(:name.asc)
          end

        end
      end

    end
    Repository = Sql::Repository
  end
end
