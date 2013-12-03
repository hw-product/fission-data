require 'fission-data'

module Fission
  module Data

    class Job < ModelBase
      bucket :jobs

      value :status, :class => String
      value :last_update, :class => Time
      value :percent_complete, :class => Fixnum
      value :payload, :class => Hash

      link :account, Account, :to => :jobs

      class << self
        def display_attributes
          [:key, :task, :status, :percent_complete, :last_update]
        end
      end

      def before_save
        super
        self.last_update = Time.now
      end

    end

  end
end
