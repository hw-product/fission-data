module Fission
  module Data
    module Sql

      class Account < Sequel::Model

        include Fission::Data::ModelInterface::Account

        many_to_one :owner, :class => Sql::User, :key => :user_id
        many_to_many :members, :class => Sql::User, :right_key => :user_id
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

          def find_stripe_customer(account_name)
            if(account_name)
              if(defined?(Stripe))
                unless(@retrieved)
                  @retrieved = []
                  until((customers = Stripe::Customer.all(:offset => @retrieved.size)).count < 1)
                    @retrieved += customers.to_a
                  end
                end
                @retrieved.detect do |customer|
                  customer.metadata[:fission_account_name] = account_name
                end
              end
            end
          end

        end

        def set_payment_information
          customer = payment_account
          if(customer)
            unless(self.stripe)
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

        # Return payment object linked to this account
        def payment_account
          if(defined?(Stripe))
            if(self.stripe_id)
              Stripe::Customer.retrieve(self.stripe_id)
            else
              ns = self.name_source || self.class.source_key(name, source)
              self.class.find_stripe_customer(ns)
            end
          end
        end

        def create_token
          self.add_token
        end

        # TODO: Update these with a proper delegate

        def stripe_id
          self.stripe.stripe_id
        end

        def subscription_id
          self.stripe.subscription_id
        end

        def subscription_plan_id
          self.stripe.subscription_plan_id
        end

        def subscription_expires
          self.stripe.subscription_expires
        end

      end

    end
    Account = Sql::Account
  end
end
