require 'fission-data'

module Fission
  module Data

    class Job < ModelBase
      bucket :jobs

      value :task, :class => String
      value :status, :class => String
      value :last_update, :class => Time
      value :percent_complete, :class => Fixnum

      link :account, Account, :to => :jobs

      class << self
        def display_attributes
          [:key, :task, :status, :percent_complete, :last_update]
        end
      end
    end

  end
end
