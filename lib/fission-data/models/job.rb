require 'fission-data'

module Fission
  module Data
    module Models

      # Job metadata
      class Job < Sequel::Model

        class << self

          # Provide model dataset with `router` unpacked from
          # the payload JSON and available for query
          #
          # @return [Sequel::Dataset]
          def dataset_with_router
            base_set = db["select * from (select j.*, string_to_array(string_agg(trim(elm::text, '\"'), ','), ',') as router from jobs j, json_array_elements(j.payload->'data'->'router') payload(elm) group by 1) _j"]
            self.dataset.from(base_set)
          end

          # Provide model dataset with `complete` unpacked from
          # the payload JSON and available for query
          #
          # @return [Sequel::Dataset]
          def dataset_with_complete
            base_set = db["select * from (select j.*, string_to_array(string_agg(trim(elm::text, '\"'), ','), ',') as complete from jobs j, json_array_elements(j.payload->'complete') payload(elm) group by 1) _j"]
            self.dataset.from(base_set)
          end

        end

        self.add_pg_typecast_on_load_columns :payload

        many_to_one :account

        def before_save
          super
          self.payload = Sequel.pg_json(self.payload)
        end

        # Validate instance attributes
        def validate
          super
          validates_presence [:message_id, :account_id]
        end

        # @return [Fission::Utils::Smash]
        def payload
          (self.values[:payload] || {}).to_smash
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
            if(self.payload.fetch(:complete, []).include?(self.payload[:job]))
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
          unless(total.empty?)
            ((done.count / total.count.to_f) * 100).to_i
          else
            -1
          end
        end

      end
    end
  end
end
