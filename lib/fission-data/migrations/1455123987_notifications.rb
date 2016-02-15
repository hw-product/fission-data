Sequel.migration do
  change do

    create_table(:notifications) do
      String :subject, :null => false
      String :message, :null => false
      DateTime :open_date
      DateTime :close_date
      DateTime :created_at, :null => false
      DateTime :updated_at
      primary_key :id
    end

    create_join_table(:account_id => :accounts, :notification_id => :notifications)
    create_join_table(:user_id => :users, :notification_id => :notifications)

    create_table(:seen_notifications) do
      foreign_key :user_id, :null => false
      foreign_key :notification_id, :null => false
      DateTime :created_at, :null => false
      primary_key [:user_id, :notification_id]
    end

  end
end
