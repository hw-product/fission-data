Sequel.migration do
  change do

    alter_table(:service_config_items) do
      add_column :format_helper, String
      add_column :position, Integer, :null => false, :default => 0
    end

  end
end
