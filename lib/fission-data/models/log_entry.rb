require 'fission-data'

module Fission
  module Data
    module Models

      # Log entries
      class LogEntry < Sequel::Model

        many_to_one :log, :class => Log
        many_to_many :tags, :class => Tag, :right_key => :tag_id, :join_table => 'log_entries_tags'

        # Add a log entry to a log
        #
        # @param args [Hash]
        # @option args [String] :log origin log file path
        # @option args [String] :source source of the entry (node ID)
        # @option args [String, Integer] :account_id account for logs
        # @option args [Array<String>] :tags tags to apply to entry
        # @option args [Integer] :timestamp log timestamp
        # @option args [String] :entry log entry
        # @return [LogEntry]
        def add(args={})
          log = Log.find_or_create(
            :path => args[:log],
            :source => args[:source],
            :account_id => args[:account_id]
          )
          tags = (args[:tags] || []).map do |tag_name|
            Tag.find_or_create(:name => tag_name.to_s)
          end
          entry = create(
            :log => log,
            :entry_time => args[:timestamp],
            :entry => args[:entry]
          )
          tags.each do |tag|
            entry.add_tag(tag)
          end
          entry
        end

      end

    end
  end
end
