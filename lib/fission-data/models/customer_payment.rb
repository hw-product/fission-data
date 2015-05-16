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
            MultiJson.load(::Stripe::Customer.retrieve(self.customer_id).to_json).to_smash
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
          ProductFeature.where(:id => plans.map(&:product_features).flatten.map(&:id))
        end

        # @return [Array<Permission>] permissions valid for this payment
        def permission_list
          Permission.where(:id => product_features.map(&:permissions).flatten.map(&:id))
        end

        # Check if permission is valid
        #
        # @param permission [Permission]
        # @return [TrueClass, FalseClass]
        def valid_permission?(permission)
          permission_list.where(:id => permission.id).count == 1
        end

      end
    end
  end
end
