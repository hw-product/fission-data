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
      column :metadata, :json
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
      DateTime :updated_at
      DateTime :created_at
      primary_key :id
      foreign_key :product_feature_id
    end

    create_join_table(:permission_id => :permissions, :token_id => :tokens)
    create_join_table(:account_id => :accounts, :permission_id => :permissions)

    create_table(:service_groups) do
      String :name, :null => false, :unique => true
      String :description
      DateTime :updated_at
      DateTime :created_at
      primary_key :id
    end

    create_table(:products) do
      String :name, :null => false, :unique => true
      String :internal_name, :null => false, :unique => true
      String :vanity_dns, :unique => true
      foreign_key :service_group_id
      DateTime :updated_at
      DateTime :created_at
      primary_key :id
    end

    create_table(:product_features) do
      String :name, :null => false
      column :data, :json
      DateTime :updated_at
      DateTime :created_at
      primary_key :id
      foreign_key :product_id, :null => false
      index [:name, :product_id], :unique => true
    end

    create_join_table(:permission_id => :permissions, :product_feature_id => :product_features)
    create_join_table(:account_id => :accounts, :product_feature_id => :product_features)

    create_table(:plans) do
      String :remote_id, :null => false, :unique => true
      String :summary
      String :description
      DateTime :updated_at
      DateTime :created_at
      primary_key :id
    end

    create_table(:repositories) do
      String :name, :null => false
      String :url, :null => false
      String :clone_url
      String :remote_id
      TrueClass :private, :null => false, :default => true
      DateTime :updated_at
      DateTime :created_at
      column :metadata, :json
      primary_key :id
      foreign_key :account_id, :null => false
    end

    create_join_table(:product_id => :products, :repository_id => :repositories)

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
      String :message_id, :null => false
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

    create_table(:static_pages) do
      String :content, :null => false
      String :title, :null => false
      String :path, :null => false
      String :style, :null => false, :default => 'haml'
      DateTime :updated_at
      DateTime :created_at
      foreign_key :product_id, :null => false
      primary_key :id
      index [:path, :product_id], :unique => true
    end

    create_table(:services) do
      String :name, :null => false, :unique => true
      String :description
      DateTime :updated_at
      DateTime :created_at
      primary_key :id
    end

    create_table(:service_groups_services) do
      Integer :position, :null => false
      foreign_key :service_group_id, :null => false
      foreign_key :service_id, :null => false
      primary_key [:service_group_id, :service_id]
      index [:service_id, :service_group_id, :position], :unique => true
    end

    create_table(:product_features_services) do
      foreign_key :product_feature_id, :null => false
      foreign_key :service_id, :null => false
      primary_key [:product_feature_id, :service_id]
      index [:service_id, :product_feature_id]
    end

    create_table(:product_features_service_groups) do
      foreign_key :product_feature_id, :null => false
      foreign_key :service_group_id, :null => false
      primary_key [:product_feature_id, :service_group_id]
      index [:service_group_id, :product_feature_id]
    end

    create_table(:service_config_items) do
      String :name, :null => false
      TrueClass :enabled, :null => false, :default => true
      String :type, :null => false, :default => 'string'
      DateTime :updated_at
      DateTime :created_at
      primary_key :id
      foreign_key :service_id, :null => false
      index [:service_id, :name], :unique => true
    end

    create_table(:account_configs) do
      String :name, :null => false
      String :description
      column :data, :json
      DateTime :updated_at
      DateTime :created_at
      foreign_key :account_id, :null => false
      primary_key :id
      index [:name, :account_id], :unique => true
    end

    create_table(:routes) do
      String :name, :null => false
      String :description
      TrueClass :enabled, :null => false, :default => true
      DateTime :updated_at
      DateTime :created_at
      foreign_key :account_id, :null => false
      primary_key :id
    end

    create_table(:routes_services) do
      foreign_key :route_id, :null => false
      foreign_key :service_id, :null => false
      Integer :position, :null => false
      primary_key [:service_id, :route_id]
      index [:route_id, :service_id], :unique => true
      index [:route_id, :service_id, :position], :unique => true
    end

    create_table(:routes_service_groups) do
      foreign_key :route_id, :null => false
      foreign_key :service_group_id, :null => false
      Integer :position, :null => false
      primary_key [:service_group_id, :route_id]
      index [:route_id, :service_group_id], :unique => true
      index [:route_id, :service_group_id, :position], :unique => true
    end

    create_table(:custom_services) do
      String :name, :null => false
      String :endpoint, :null => false
      TrueClass :enabled, :null => false, :default => true
      foreign_key :account_id, :null => false
      primary_key :id
      index [:name, :account_id], :unique => true
    end

    create_table(:custom_services_routes) do
      foreign_key :route_id, :null => false
      foreign_key :custom_service_id, :null => false
      Integer :position, :null => false
      primary_key [:custom_service_id, :route_id]
      index [:route_id, :custom_service_id], :unique => true
      index [:route_id, :custom_service_id, :position], :unique => true
    end

    create_table(:route_configs) do
      String :name, :null => false
      String :description
      Integer :position, :null => false
      foreign_key :route_id, :null => false
      index [:name, :route_id], :unique => true
      index [:name, :route_id, :position], :unique => true
      primary_key :id
    end

    create_table(:payload_match_rules) do
      String :name, :null => false, :unique => true
      String :payload_key, :null => false, :unique => true
      String :description
      primary_key :id
    end

    create_table(:payload_matchers) do
      String :value, :null => false
      foreign_key :account_id, :null => false
      foreign_key :payload_match_rule_id, :null => false
      primary_key :id
    end

    create_join_table(:payload_matcher_id => :payload_matchers, :route_config_id => :route_configs)

    create_table(:account_configs_route_configs) do
      foreign_key :account_config_id, :null => false
      foreign_key :route_config_id, :null => false
      Integer :position, :null => false
      primary_key [:account_config_id, :route_config_id]
      index [:route_config_id, :account_config_id, :position], :unique => true
    end

    create_join_table(:payload_matcher_id => :payload_matchers, :route_id => :routes)
    create_join_table(:repository_id => :repositories, :route_id => :routes)
  end
end
