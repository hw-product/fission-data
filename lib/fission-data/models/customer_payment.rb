require 'fission-data'

module Fission
  module Data
    module Models
      # Customer payment proxy
      class CustomerPayment < Sequel::Model

        # @return [Hash] remote account data
        attr_reader :remote_data
        many_to_one :account, :class => Account

        class << self

          # Retrieve customer payment information
          # from remote API
          #
          # @param [Account]
          # @return [NilClass, CustomerPayment]
          def remote_load(account)
            stripe_load(account)
          end

          # Retrieve customer payment information
          # from remote API
          #
          # @param [Account]
          # @return [NilClass, CustomerPayment]
          def stripe_load(account)
            customer = remote_metadata('stripe',
              :fission_account => account.expanded_name
            )
            if(customer)
              CustomerPayment.find_by_customer_id(customer.id) || CustomerPayment.create(
                :account_id => account.id,
                :customer_id => customer.id,
                :type => 'stripe'
              )
            end
          end

          # Retrieve metadata from remote location
          #
          # @param location [String] remote location
          # @param identifier [String, Hash]
          # @return [Hash, NilClass]
          def remote_metadata(location, identifier)
            case location
            when 'stripe'
              if(defined?(::Stripe))
                unless(@stripe_list)
                  @stripe_list = ::Stripe::Customer.all.to_a
                end
                @stripe_list.detect do |stripe|
                  if(identifier.is_a?(Hash))
                    identifier.all do |key, value|
                      stripe.metadata[key.to_sym] == value
                    end
                  else
                    stripe.id == identifier
                  end
                end
              end
            end
          end
        end

        def before_save
          super
          self.remote_plans ||= {}
          self.remote_plans = Sequel.pg_json(self.remote_plans)
        end

        # Validate model attributes
        def validate
          super
          validate_presence [:account_id, :customer_id, :type]
        end

        # Check if permission is valid
        #
        # @param permission [Permission]
        # @return [TrueClass, FalseClass]
        def valid_permission?(permission)
          permission_list.where(:id => permission.id).count > 0
        end

        # @return [Fission::Data::Models::ProductFeature::Dataset]
        def product_features
          case type
          when 'stripe'
            feature_ids = remote_data.fetch(:subscriptions, :data, []).map do |subscription|
              subscription.get(:plan, :metadata, :fission_product_features).to_s.split(',')
            end.compact.flatten.uniq.map(&:to_i)
            ProductFeature.dataset.where(:id => feature_ids)
          else
            ProductFeature.dataset.where(:id => nil)
          end
        end

        # @return [Sequel::Dataset] permissions valid for this payment
        def permission_list
          case type
          when 'stripe'
            Permission.dataset.where(
              :product_feature_id => features.select(:id).all.map(&:id)
            )
          else
            []
          end
        end

        # @return [Hash] payment metadata
        def metadata
          load_data!
          case type
          when 'stripe'
            remote_data.get(:metadata)
          else
            {}
          end
        end

        # @return [Hash] remote data
        def load_data!
          unless(remote_data)
            case type
            when 'stripe'
              data = ::Stripe::Customer.retrieve(
                self.customer_id
              )
            end
            @remote_data = (data || {}).to_smash
          end
        end

        # @return [Fission::Utils::Smash]
        def remote_plans
          unless(self.values[:remote_plans].is_a?(Smash))
            self.values[:remote_plans] = (self.values[:remote_plans] || {}).to_smash
          end
          self.values[:remote_plans]
        end

      end
    end
  end
end
