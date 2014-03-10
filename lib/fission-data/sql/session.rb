module Fission
  module Data
    module Sql

      class Session < BaseModel

        self.add_pg_typecast_on_load_columns :data

        many_to_one :user, :class => Sql::User

        def validate
          super
          validates_presence :user_id
        end

      end

    end
    Session = Sql::Session
  end
end
