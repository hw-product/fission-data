module Fission
  module Data
    module Sql

      class Tag < Sequel::Model

        include Fission::Data::ModelInterface::Tag

        many_to_many :log_entries, :class => Sql::LogEntry, :right_key => :log_entry_id, :join_table => 'log_entries_tags'

        def validate
          super
          validates_unique [:name]
        end

      end

    end
    Tag = Sql::Tag
  end
end
