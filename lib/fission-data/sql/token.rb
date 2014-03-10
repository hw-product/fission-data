module Fission
  module Data
    module Sql

      class Token < BaseModel

        many_to_many :users, :class => Sql::User
        many_to_many :accounts, :class => Sql::Account

        def validate
          super
          validates_presence :token
          validates_unique :token
        end

      end

    end
    Token = Sql::Token
  end
end
