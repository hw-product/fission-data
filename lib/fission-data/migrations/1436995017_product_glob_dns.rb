Sequel.migration do
  change do
    alter_table(:products) do
      add_column :glob_dns, String
    end
  end
end
