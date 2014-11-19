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
            dataset_with(:collections => {:router => ['data', 'router', 'route']})
          end

          # Provide model dataset with `complete` unpacked from
          # the payload JSON and available for query
          #
          # @return [Sequel::Dataset]
          def dataset_with_complete
            dataset_with(:collections => {:complete => ['complete']})
          end

          # Construct customized dataset with JSON attributes extracted
          #
          # @param hash [Hash] query options
          # @option hash [Hash] :collections - {:alias_key => ['path', 'to', 'collection']
          # @option hash [Hash] :scalars - {:alias_key => ['path', 'to', 'scalar']
          # @return [Sequel::Dataset]
          # @note only one collection can be provided at this time
          def dataset_with(hash={})
            collections = hash.fetch(:collections, {})
            scalars = hash.fetch(:scalars, {})
            raise ArgumentError.new "Only one item allowed with `:collections`" if collections.size > 1
            customs = [["jobs.*", "jobs as jobs"]]
            customs += collections.map do |key, location|
              [
                "string_to_array(string_agg(trim(elm::text, '\"'), ','), ',') as #{key}",
                "json_array_elements(jobs.payload->'#{location.join("'->'")}') payload(elm)"
              ]
            end
            customs += scalars.map do |key, location|
              location = ['payload'] + location
              [
                [location.first, location.slice(1, location.size - 2).map{|x| "'#{x}'"}].flatten.compact.join('->') << "->>'#{location.last}' as #{key}",
                nil
              ]
            end
            self.dataset.from(Sequel.lit("(select #{customs.map(&:first).join(', ')} from #{customs.map(&:last).compact.join(', ')} group by jobs.id) jobs"))
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
