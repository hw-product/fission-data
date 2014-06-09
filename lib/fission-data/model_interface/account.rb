module Fission
  module Data
    module ModelInterface

      # Account model base
      module Account

        module ClassMethods
        end

        module InstanceMethods
        end

        class << self

          # Load commons
          #
          # @param klass [Class]
          def included(klass)
            klass.class_eval do
              class << self

                # @return [Array<String,Symbol>] attributes to display
                def display_attributes
                  [:name, :source, :owner]
                end

                # Filter items based on user
                #
                # @param user [Fission::Data::User]
                # @return [Dataset]
                def restrict(user)
                  ([user.base_account] + user.managed_accounts).compact.uniq
                end

                # Find strip account
                #
                # @param account_name [String]
                # @return [Stripe::Customer]
                def find_stripe_customer(account_name)
                  if(account_name)
                    if(defined?(::Stripe))
                      unless(@retrieved)
                        @retrieved = ::Stripe::Customer.all.to_a
                        # TODO: looping gets us a weird threading error
=begin
                           @retrieved = []
                           until((customers = ::Stripe::Customer.all(:offset => @retrieved.size)).count < 1)
                             @retrieved += customers.to_a
                           end
=end
                      end
                      @retrieved.detect do |customer|
                        customer.metadata[:fission_account_name] = account_name
                      end
                    end
                  end
                end

              end

              # @return [TrueClass, FalseClass] account has subscription
              def subscribed?
                !!subscription_id
              end

              # @return [TrueClass, FalseClass] subscription is expired
              def expired?
                if(subscription_expires)
                  subscription_expires < Time.now.to_i
                else
                  false
                end
              end

              # @return [TrueClass, FalseClass] account is active (valid subscription)
              def active?
                subscribed? && !expired?
              end

              # User is an owner of account
              #
              # @param user Fission::Data::Instance
              # @return [TrueClass, FalseClass]
              def owner?(user)
                user == owner || owners.include?(user)
              end

              # @return [Array<String,Symbol>] links to display
              def display_links(user)
                if(owner?(user))
                  super
                else
                  []
                end
              end

              # @return [Stripe::Customer] payment object for this account
              def payment_account
                if(defined?(::Stripe))
                  if(self.stripe_id)
                    ::Stripe::Customer.retrieve(self.stripe_id)
                  else
                    ns = self.name_source || self.class.source_key(name, source)
                    self.class.find_stripe_customer(ns)
                  end
                end
              end

            end

          end

        end

      end

    end
  end
end
