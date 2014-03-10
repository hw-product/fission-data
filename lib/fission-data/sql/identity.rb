module Fission
  module Data
    module Sql

      class Identity < BaseModel

        self.add_pg_typecast_on_load_columns :credentials, :extras, :infos

        many_to_one :user, :class => Sql::User

        def validate
          super
          validates_presence [:uid, :user_id]
        end

      end

    end
    Identity = Sql::Identity
  end
end
