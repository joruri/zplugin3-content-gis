class CreateGisFolders < ActiveRecord::Migration[5.0]
  def change
    create_table :gis_folders do |t|
      t.belongs_to :map
      t.string :state
      t.string :title
      t.text :body
      t.text :message
      t.integer :sort_no
      t.timestamps
    end
  end
end
