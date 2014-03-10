Sequel.migration do
  change do

    create_table(:origins) do
      String :name, :null => false, :unique => true
      primary_key :id
    end

    create_table(:users) do
      String :username, :null => false, :unique => true
      String :name
      DateTime :updated_at
      DateTime :created_at
      foreign_key :origin_id, :null => false
      primary_key :id
      index [:id, :origin_id], :unique => true
    end

    create_table(:accounts) do
      String :name, :null => false, :unique => true
      DateTime :updated_at
      DateTime :created_at
      foreign_key :user_id
      foreign_key :origin_id, :null => false
      primary_key :id
      index [:id, :origin_id], :unique => true
    end

    create_join_table(:account_id => :accounts, :user_id => :users)

    create_table(:stripes) do
      String :stripe_id, :null => false, :unique => true
      String :subscription_id
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
      column :metadata, :hstore
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
      column :credentials, :hstore
      column :extras, :hstore
      column :infos, :hstore
      foreign_key :user_id, :null => false
      primary_key :id
    end

    create_table(:sessions) do
      DateTime :updated_at
      DateTime :created_at
      column :data, :hstore
      foreign_key :user_id, :null => false
      primary_key :id
    end

    create_table(:jobs) do
      String :message_id, :null => false, :unique => true
      DateTime :updated_at
      DateTime :created_at
      column :payload, :hstore
      foreign_key :account_id, :null => false
      primary_key :id
    end

  end
end
