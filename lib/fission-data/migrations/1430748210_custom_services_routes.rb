Sequel.migration do
  change do

    create_table(:custom_services_routes) do
      foreign_key :route_id, :null => false
      foreign_key :custom_service_id, :null => false
      Integer :position, :null => false
      primary_key [:custom_service_id, :route_id]
      index [:route_id, :custom_service_id], :unique => true
      index [:route_id, :custom_service_id, :position], :unique => true
    end

  end
end
