require 'fission-data'

module Fission
  module Data
    module Models

      # Tag data
      class Tag < Sequel::Model

        many_to_many :log_entries, :class => LogEntry, :right_key => :log_entry_id, :join_table => 'log_entries_tags'

        # Validate instance attributes
        def validate
          super
          validates_unique [:name]
          validates_presence [:name]
        end

      end

    end
  end
end
