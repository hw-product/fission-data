Sequel.migration do
  change do

    create_table(:sources) do
      String :name, :null => false, :unique => true
      primary_key :id
    end

    create_table(:users) do
      String :username, :null => false, :unique => true
      String :name
      DateTime :updated_at
      DateTime :created_at
      foreign_key :source_id, :null => false
      primary_key :id
      index [:id, :source_id], :unique => true
    end

    create_table(:accounts) do
      String :name, :null => false, :unique => true
      String :email
      DateTime :updated_at
      DateTime :created_at
      foreign_key :user_id
      foreign_key :source_id, :null => false
      primary_key :id
      index [:id, :source_id], :unique => true
    end

    create_table(:accounts_members) do
      foreign_key :account_id, :accounts, :null => false
      foreign_key :user_id, :users, :null => false
      primary_key [:account_id, :user_id]
      index [:user_id, :account_id]
    end

    create_table(:accounts_owners) do
      foreign_key :account_id, :accounts, :null => false
      foreign_key :user_id, :users, :null => false
      primary_key [:account_id, :user_id]
      index [:user_id, :account_id]
    end

    create_table(:stripes) do
      String :stripe_id, :null => false
      String :subscription_id
      String :subscription_plan_id
      Integer :subscription_expires
      foreign_key :account_id, :null => false
      primary_key :id
    end

    create_table(:tokens) do
      String :token, :null => false, :unique => true
      DateTime :updated_at
      DateTime :created_at
      primary_key :id
    end

    create_join_table(:account_id => :accounts, :token_id => :tokens)
    create_join_table(:user_id => :users, :token_id => :tokens)

    create_table(:repositories) do
      String :name, :null => false
      String :url, :null => false
      String :clone_url
      TrueClass :private, :null => false, :default => true
      DateTime :updated_at
      DateTime :created_at
      column :metadata, :json
      primary_key :id
      foreign_key :account_id, :null => false
    end

    create_table(:identities) do
      String :uid, :null => false
      String :provider
      String :email
      DateTime :updated_at
      DateTime :created_at
      String :password_digest
      String :credentials
      column :extras, :json
      column :infos, :json
      foreign_key :user_id, :null => false
      foreign_key :source_id, :null => false
      primary_key :id
    end

    create_table(:sessions) do
      DateTime :updated_at
      DateTime :created_at
      column :data, :json
      foreign_key :user_id, :null => false
      primary_key :id
    end

    create_table(:jobs) do
      String :message_id, :null => false, :unique => true
      DateTime :updated_at
      DateTime :created_at
      column :payload, :json
      foreign_key :account_id, :null => false
      primary_key :id
    end

    create_table(:tags) do
      String :name, :null => false, :unique => true
      DateTime :updated_at
      DateTime :created_at
      primary_key :id
    end

    create_table(:logs) do
      String :path, :null => false
      String :source, :null => false
      DateTime :updated_at
      DateTime :created_at
      index [:path, :source], :unique => true
      foreign_key :account_id
      primary_key :id
    end

    create_table(:log_entries) do
      String :entry, :null => false
      Float :entry_time, :null => false
      DateTime :updated_at
      DateTime :created_at
      foreign_key :log_id, :null => false
      primary_key :id
    end

    create_join_table(:log_entry_id => :log_entries, :tag_id => :tags)

  end
end
