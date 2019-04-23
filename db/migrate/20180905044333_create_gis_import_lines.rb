class CreateGisImportLines < ActiveRecord::Migration[5.0]
  def change
    create_table :gis_import_lines do |t|
      t.integer :import_id
      t.integer :line_no
      t.jsonb   :data
      t.string  :data_type
      t.jsonb   :data_attributes
      t.jsonb   :data_extras
      t.integer :data_invalid
      t.jsonb   :data_errors
      t.geometry :geom, srid: 4326
      t.timestamps
    end
  end
end
