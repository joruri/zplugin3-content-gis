class AddBodyToGisRecommends < ActiveRecord::Migration[5.2]
  def change
    add_column :gis_recommends, :body, :text
  end
end
