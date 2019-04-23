class CreateGisLayers < ActiveRecord::Migration[5.0]
  def change
    create_table :gis_layers do |t|
      t.belongs_to :content
      t.string    :state
      t.string    :title
      t.string    :name
      t.text      :body
      t.integer   :db_id
      t.jsonb     :item_values
      t.integer   :sort_no
      t.string    :kind
      t.float     :opacity
      t.string    :extent
      t.boolean   :use_export_csv
      t.boolean   :use_export_kml
      t.boolean   :use_export_kml_no_label
      t.boolean   :use_slideshow
      t.integer   :srid
      t.string    :geometry_type
      t.timestamps
    end
  end
end
