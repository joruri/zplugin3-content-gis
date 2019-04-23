class CreateGisGeocodingEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :gis_geocoding_entries do |t|
      t.belongs_to :content
      t.string   :state
      t.integer  :requestable_id
      t.string   :requestable_type
      t.string   :address
      t.float    :lat
      t.float    :lng
      t.geometry :geom, srid: 4326
      t.timestamps
    end
  end
end
