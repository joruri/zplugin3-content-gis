class CreateGisCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :gis_categories do |t|
      t.belongs_to :concept
      t.belongs_to :content
      t.belongs_to :parent
      t.string  :state
      t.string  :name
      t.string  :title
      t.integer :level_no
      t.integer :sort_no
      t.integer :children_count, :null => false, :default => 0
      t.timestamps
    end
  end
end
