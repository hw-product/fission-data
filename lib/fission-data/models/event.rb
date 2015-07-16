require 'fission-data'

module Fission
  module Data
    module Models

      # Events
      class Event < Sequel::Model

        def validate
          super
          validates_presence [:type, :stamp]
        end

        def before_save
          super
          self.data ||= {}
          self.data = Sequel.pg_json(self.data)
        end

        # @return [Job, NilClass]
        def job
          if(self.message_id)
            Job.current_dataset.where(:message_id => self.message_id).first
          end
        end

        # @return [Time, NilClass] event origination time
        def stamp
          if(self[:stamp])
            Time.at(self[:stamp])
          end
        end

        # @return [Fission::Utils::Smash]
        def data
          unless(self.values[:data].is_a?(Smash))
            self.values[:data] = (self.values[:data] || {}).to_smash
          end
          self.values[:data]
        end

      end

    end
  end
end
