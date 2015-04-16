Sequel.migration do
  change do

    create_table(:account_configs) do
      String :service_name, :null => false
      column :data, :json
      foreign_key :account_id, :null => false
      primary_key :id
      index [:account_id, :service_name], :unique => true
    end

  end
end
