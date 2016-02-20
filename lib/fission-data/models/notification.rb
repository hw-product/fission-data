require 'fission-data'

module Fission
  module Data
    module Models

      # Notification
      class Notification < Sequel::Model

        many_to_many :accounts
        many_to_many :users
        many_to_many :app_event_matchers
        many_to_many :seen_users, :class => User, :right_key => :user_id, :join_table => 'seen_notifications'

        # Validate notification attributes
        def validate
          super
          validates_presence :subject
          validates_presence :message
        end

        # @return [TrueClass, FalseClass]
        def closed?
          if(close_date)
            Time.now.to_datetime > close_date
          else
            false
          end
        end

        # @return [TrueClass, FalseClass]
        def open?
          if(open_date)
            Time.now.to_datetime > open_date && !closed?
          else
            !closed?
          end
        end

      end
    end
  end
end
