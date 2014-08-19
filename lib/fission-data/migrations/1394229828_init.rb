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
      index [:username, :source_id], :unique => true
    end

    create_table(:accounts) do
      String :name, :null => false, :unique => true
      String :email
      DateTime :updated_at
      DateTime :created_at
      foreign_key :user_id, :null => false
      foreign_key :source_id, :null => false
      primary_key :id
      index [:name, :source_id], :unique => true
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

    create_table(:customer_payments) do
      String :customer_id, :null => false
      String :type, :null => false
      foreign_key :account_id, :null => false
    end

    create_table(:tokens) do
      String :token, :null => false, :unique => true
      DateTime :updated_at
      DateTime :created_at
      primary_key :id
      foreign_key :user_id
      foreign_key :account_id
    end

    create_table(:permissions) do
      String :name, :null => false, :unique => true
      String :pattern, :null => false
      TrueClass :customer_validate, :null => false, :default => false
      primary_key :id
      foreign_key :product_id
    end

    create_join_table(:permission_id => :permissions, :token_id => :tokens)
    create_join_table(:account_id => :accounts, :permission_id => :permissions)

    create_table(:products) do
      String :name, :null => false, :unique => true
      String :vanity_dns, :unique => true
      primary_key :id
    end

    create_table(:product_features) do
      String :name, :null => false
      column :data, :json
      primary_key :id
      foreign_key :product_id, :null => false
      index [:name, :product_id], :unique => true
    end

    create_table(:plans) do
      String :remote_id, :null => false, :unique => true
      String :summary
      String :description
      primary_key :id
    end

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
      foreign_key :account_id, :null => false
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

    create_table(:whitelists) do
      String :username, :null => false
      foreign_key :creator_id, :null => false
      primary_key :id
    end

    ## Seed ##

    source = Fission::Data::Models::Source.create(:name => github)
    user = source.add_user(:username => 'fission_default_admin')
    user.owned_accounts.add_permission(:name => 'global', :pattern => '/.*')
    user.add_whitelist(:username => 'fission_default_admin')

  end
end
