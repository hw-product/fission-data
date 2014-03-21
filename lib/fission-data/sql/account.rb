module Fission
  module Data
    module Sql

      class Account < Sequel::Model

        many_to_one :owner, :class => Sql::User
        many_to_many :members, :class => Sql::User, :right_key => :user_id
        one_to_many :jobs, :class => Sql::Job
        one_to_many :repositories, :class => Sql::Repository
        many_to_many :tokens, :class => Sql::Token
        one_to_many :stripes, :class => Sql::Stripe
        many_to_one :source, :class => Sql::Source

        def validate
          super
          validates_presence :name
        end

      end

    end
    Account = Sql::Account
  end
end
