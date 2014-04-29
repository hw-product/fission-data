module Fission
  module Data
    module Sql

      class Log < Sequel::Model

        include Fission::Data::ModelInterface::Log

        one_to_many :log_entries, :class => Sql::LogEntry
        many_to_one :account, :class => Sql::Account

        def validate
          super
          validates_unique [:path, :source]
        end

      end

    end
    Log = Sql::Log
  end
end
