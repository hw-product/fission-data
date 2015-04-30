Sequel.migration do
  change do

    create_table(:custom_services) do
      String :name, :null => false
      String :endpoint, :null => false
      TrueClass :enabled, :null => false, :default => true
      foreign_key :account_id, :null => false
      primary_key :id
      add_index [:name, :account_id], :unique => true
    end

  end
end
