Sequel.migration do
  change do

    create_join_table(
      {:product_id => :products, :enabled_product_id => :products},
      :name => :products_enabled_products
    )

  end
end
