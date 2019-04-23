class CreateGisFoldersLayers < ActiveRecord::Migration[5.0]
  def change
    create_table :gis_folders_layers do |t|
      t.belongs_to :folder
      t.belongs_to :layer
      t.string     :state
      t.integer    :sort_no
      t.timestamps
    end
  end
end
