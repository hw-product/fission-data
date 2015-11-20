Sequel.migration do
  change do

    alter_table(:services) do
      add_column :icon, String
      add_column :alias, String
    end

  end
end
