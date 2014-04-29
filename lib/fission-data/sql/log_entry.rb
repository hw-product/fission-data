module Fission
  module Data
    module Sql

      class LogEntry < Sequel::Model

        include Fission::Data::ModelInterface::LogEntry

        many_to_one :log, :class => Sql::Log
        many_to_many :tags, :class => Sql::Tag, :right_key => :tag_id, :join_table => 'log_entries_tags'

      end

    end
    LogEntry = Sql::LogEntry
  end
end
