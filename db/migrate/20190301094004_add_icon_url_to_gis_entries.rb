class AddIconUrlToGisEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :gis_entries, :icon_uri, :string
  end
end
