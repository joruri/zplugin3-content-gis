class CreateGisRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :gis_registrations do |t|
      t.belongs_to :concept
      t.belongs_to :content
      t.belongs_to :entry
      t.string   :state
      t.float    :lat
      t.float    :lng
      t.geometry :geom, srid: 4326
      t.string   :geometry_type
      t.string   :title
      t.string   :name
      t.string   :email
      t.text     :description
      t.integer  :db_id
      t.jsonb    :item_values
      t.timestamps
    end
  end
end
