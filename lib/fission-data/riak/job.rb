require 'fission-data'

module Fission
  module Data
    module Riak
      class Job < ModelBase

        include Fission::Data::ModelInterface::Job

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

          def sorter(i)
            i.sort_by!(&:last_update).reverse
          end

        end

        def before_save
          super
          self.last_update = Time.now.to_i
        end

      end

    end
    Job = Riak::Job
  end
end
