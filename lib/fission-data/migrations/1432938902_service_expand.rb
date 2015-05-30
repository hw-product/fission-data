Sequel.migration do
  change do

    alter_table(:services) do
      add_column :category, String
    end

    alter_table(:service_config_items) do
      add_column :description, String
    end

  end
end
