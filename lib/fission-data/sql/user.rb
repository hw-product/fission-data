module Fission
  module Data
    module Sql

      class User < Sequel::Model

        include Fission::Data::ModelInterface::User

        # TODO: base acct
        one_to_one :base_account, :class => Sql::Account
        one_to_many :accounts, :class => Sql::Account
        one_to_one :active_session, :class => Sql::Session
        many_to_many :managed_accounts, :class => Sql::Account, :right_key => :account_id
        one_to_many :identities, :class => Sql::Identity
        many_to_one :source, :class => Sql::Source

        def validate
          super
          validates_presence :username
        end

      end

    end
    User = Sql::User
  end
end
