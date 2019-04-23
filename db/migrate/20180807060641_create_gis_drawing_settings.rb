class CreateGisDrawingSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :gis_drawing_settings do |t|
      t.belongs_to :layer
      t.jsonb   :data_condition
      t.text    :geometry_type
      t.text    :label_column
      t.text    :label_color
      t.text    :point_color
      t.text    :line_color
      t.text    :line_width
      t.text    :polygon_color
      t.string  :label_position
      t.integer :point_fill
      t.integer :line_fill
      t.integer :polygon_fill
      t.integer :label_size
      t.timestamps
    end
  end
end
