module Fission
  module Data
    module Sql

      class Stripe < BaseModel

        many_to_one :account, :class => Sql::Account

        def validate
          super
          validates_presence :stripe_id
          validates_unique :stripe_id
        end

      end

    end
    Stripe = Sql::Stripe
  end
end
