class AddIconUrlToGisCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :gis_categories, :icon_uri, :string
  end
end
