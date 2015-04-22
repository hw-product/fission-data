Sequel.migration do
  change do

    create_table(:routes) do
      String :name, :null => false
      String :description
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

  end
end
