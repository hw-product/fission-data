module Fission
  module Data
    module Sql

      class Source < BaseModel

        one_to_many :users, :class => Sql::User
        one_to_many :accounts, :class => Sql::User

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
