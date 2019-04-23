class CreateGisRecommends < ActiveRecord::Migration[5.0]
  def change
    create_table :gis_recommends do |t|
      t.belongs_to :content
      t.string    :state
      t.string    :title
      t.string    :name
      t.string    :operator_type
      t.integer   :db_id
      t.jsonb     :item_values
      t.integer   :sort_no
      t.boolean   :equip_cond
      t.timestamps
    end
  end
end
