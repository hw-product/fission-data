Sequel.migration do
  change do

    alter_table(:plans) do
      add_column :trial_days, Integer
    end

  end
end
