class AddBodyToGisEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :gis_entries, :body, :text
    add_column :gis_entries, :summary, :text
  end
end
