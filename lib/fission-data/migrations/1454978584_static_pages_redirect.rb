Sequel.migration do
  change do

    alter_table(:static_pages) do
      add_column :redirect_url, String
    end

  end
end
