Sequel.migration do
  change do

    create_table(:app_event_matchers) do
      String :pattern, :null => false, :unique => true
      primary_key :id
    end

    create_join_table(:app_event_matcher_id => :app_event_matchers, :notification_id => :notifications)

  end
end
