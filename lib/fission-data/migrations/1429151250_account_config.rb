Sequel.migration do
  change do

    create_table(:services) do
      String :name, :null => false, :unique => true
      String :description
      DateTime :updated_at
      DateTime :created_at
      primary_key :id
    end

    create_table(:service_groups) do
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
      DateTime :updated_at
      DateTime :created_at
      primary_key :id
      foreign_key :service_id, :null => false
      index [:service_id, :name], :unique => true
    end

    create_table(:account_configs) do
      column :data, :json
      DateTime :updated_at
      DateTime :created_at
      foreign_key :service_id, :null => false
      foreign_key :account_id, :null => false
      primary_key :id
      index [:account_id, :service_id], :unique => true
    end

  end
end
