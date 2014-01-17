require 'fission-data'

module Fission
  module Data

    class Job < ModelBase
      bucket :jobs

      value :last_update, :class => Fixnum
      value :payload, :class => Hash
      value :message_id, :class => String

      index :message_id, :unique => true
      link :account, Account, :to => :jobs

      class << self

        def restrict(user)
          [user.base_account, user.managed_accounts].flatten.compact.map do |act|
            act.jobs || []
          end.flatten.compact
        end

        def display_attributes
          [:key, :task, :status, :percent_complete, :last_update]
        end

      end

      def before_save
        super
        self.last_update = Time.now.to_i
      end

      def task
        'packaging'
      end

      def status
        'in progress'
      end

      def percent_complete
        75
      end

    end

  end
end
