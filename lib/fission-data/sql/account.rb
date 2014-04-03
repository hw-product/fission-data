module Fission
  module Data
    module Sql

      class Account < Sequel::Model

        include Fission::Data::ModelInterface::Account

        many_to_one :owner, :class => Sql::User, :key => :user_id
        many_to_many :owners, :class => Sql::User, :right_key => :user_id, :join_table => 'accounts_owners'
        many_to_many :members, :class => Sql::User, :right_key => :user_id, :join_table => 'accounts_members'
        one_to_many :jobs, :class => Sql::Job
        one_to_many :repositories, :class => Sql::Repository
        many_to_many :tokens, :class => Sql::Token
        one_to_one :stripe, :class => Sql::Stripe
        many_to_one :source, :class => Sql::Source

        def validate
          super
          validates_presence :name
        end

        class << self
          def lookup(name, source, *args)
            account = Source.find_by_name(source).accounts_dataset.where(:name => name).first
            if(account.nil? && args.include?(:remote))
              account = remote_lookup(name, source)
            end
            account
          end

          def remote_lookup(name, source)
            customer = find_stripe_customer(source_key(name, source))
            source = Source.find_by_name(source)
            account = self.new(
              :name => name,
              :source => source
            )
            account.set_payment_information if customer
            account
          end

        end

        def set_payment_information
          customer = payment_account
          if(customer)
            unless(self.stripe)
              self.save if self.new?
              self.stripe = Stripe.new(:stripe_id => customer.id)
            end
            if(customer.subscription)
              self.stripe.subscription_id = customer.subscription.id
              self.stripe.subscription_plan_id = customer.subscription.plan.id
              self.stripe.subscription_expires = customer.subscription.current_period_end
            end
            self.stripe.save if self.stripe.modified?
            true
          else
            false
          end
        end

        def create_token
          self.add_token
        end

        # TODO: Update these with a proper delegate

        def stripe_id
          if(self.stripe)
            self.stripe.stripe_id
          end
        end

        def subscription_id
          if(self.stripe)
            self.stripe.subscription_id
          end
        end

        def subscription_plan_id
          if(self.stripe)
            self.stripe.subscription_plan_id
          end
        end

        def subscription_expires
          if(self.stripe)
            self.stripe.subscription_expires
          end
        end

      end

    end
    Account = Sql::Account
  end
end
