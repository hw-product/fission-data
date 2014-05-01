module Fission
  module Data
    module Sql

      class Session < Sequel::Model

        include Fission::Data::ModelInterface::Session

        many_to_one :user, :class => Sql::User

        self.add_pg_typecast_on_load_columns :data

        def validate
          super
          validates_presence :user_id
        end

        def before_save
          super
          self.data = Sequel.pg_json(self.data)
        end

      end

    end
    Session = Sql::Session
  end
end
