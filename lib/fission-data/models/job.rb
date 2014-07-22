require 'fission-data'

module Fission
  module Data
    module Models

      # Job metadata
      class Job < Sequel::Model

        self.add_pg_typecast_on_load_columns :payload

        many_to_one :account, :class => Account

        # Validate instance attributes
        def validate
          super
          validates_presence [:message_id, :account_id]
        end

        # @return [Fission::Utils::Smash]
        def payload
          (self.payload || {}).to_smash
        end

        # @return [String] task of job
        def task
          self.payload.fetch(:data, :router, :action, self.payload[:job])
        end

        # @return [Symbol] current job status
        def status
          if(self.payload[:error])
            :error
          else
            if(self.payload[:complete].include?(self.payload[:job]))
              :complete
            else
              :in_progress
            end
          end
        end

        # @return [Integer] percentage of job completed
        def percent_complete
          done = self.payload.fetch(:complete, []).find_all do |j|
            !j.include?(':')
          end
          total = [done, self.payload.fetch(:data, :router, :route, [])].flatten.compact
          ((done.count / total.count.to_f) * 100).to_i
        end

      end
    end
  end
end
