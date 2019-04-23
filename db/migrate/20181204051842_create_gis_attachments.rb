class CreateGisAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :gis_attachments do |t|
      t.belongs_to :site
      t.belongs_to :registration
      t.string :name
      t.text :title
      t.text :mime_type
      t.integer :size
      t.integer :image_is
      t.integer :image_width
      t.integer :image_height
      t.binary :data
      t.integer :thumb_width
      t.integer :thumb_height
      t.integer :thumb_size
      t.binary :thumb_data
      t.timestamps
    end
  end
end
