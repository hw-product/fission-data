require 'fission-data'

module Fission
  module Data
    module Models
      # Customer payment proxy
      class CustomerPayment < Sequel::Model

#        include Bogo::Memoization

        # @return [Hash] remote account data
        attr_reader :remote_data
        many_to_one :account, :class => Account

        # Validate model attributes
        def validate
          super
          validates_presence [:account_id, :customer_id, :type]
          validates_unique [:account_id, :type]
        end

        # @return [Smash] remote customer data
        def remote_data
#          memoize(:remote_data) do
            ::Stripe::Customer.retrieve(self.customer_id).to_hash.to_smash
#          end
        end


        # !!! TODO: Add filtering on subscription for "active"-type status


        # @return [Array<Plan>]
        def plans
          plan_ids = remote_data.fetch(:subscriptions, :data, []).map do |subscription|
            subscription.get(:plan, :metadata, :fission_plans).to_s.split(',')
          end.flatten.compact.uniq.map(&:to_i)
          Plan.where(:id => plan_ids).all
        end

        # @return [Array<ProductFeature>]
        def product_features
          plans.map(&:product_features).uniq
        end

        # @return [Array<Permission>] permissions valid for this payment
        def permission_list
          product_features.map(&:permissions).uniq
        end

        # Check if permission is valid
        #
        # @param permission [Permission]
        # @return [TrueClass, FalseClass]
        def valid_permission?(permission)
          permission_list.include?(permission)
        end

      end
    end
  end
end
