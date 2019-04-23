class AddIconUrlToGisRecommends < ActiveRecord::Migration[5.2]
  def change
    add_column :gis_recommends, :icon_uri, :string
  end
end
