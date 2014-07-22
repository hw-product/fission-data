require 'fission-data'

module Fission
  module Data
    module Models

      # Log file container
      class Log < Sequel::Model

        one_to_many :log_entries, :class => LogEntry
        many_to_one :account, :class => Account

        # Validate instance attributes
        def validate
          super
          validates_unique [:path, :source]
          validates_presence [:path, :source, :account_id]
        end

      end

    end
  end
end
