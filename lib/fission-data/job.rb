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

        def sorter(i)
          i.sort_by!(&:last_update).reverse
        end

      end

      def before_save
        super
        self.last_update = Time.now.to_i
      end

      def task
        Fission::Data::Hash.walk_get(self.payload, :data, :router, :action) || self.payload['job']
      end

      def status
        if(self.payload['error'])
          :error
        else
          self.payload['complete'].include?(self.payload['job']) ? :complete : :in_progress
        end
      end

      def percent_complete
        total = [
          done = Hash.walk_get(self.payload, :complete).find_all{|x|!x.include?(':')},
          Hash.walk_get(self.payload, :data, :router, :route)
        ].flatten.compact
        ((done.count / total.count.to_f) * 100).to_i
      end

    end

  end
end
