module Fission
  module Data
    module Sql

      class Source < Sequel::Model

        one_to_many :users, :class => Sql::User
        one_to_many :accounts, :class => Sql::Account

        def validate
          super
          validates_presence :name
          validates_unique :name
        end

      end

    end
    Source = Sql::Source
  end
end
