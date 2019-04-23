class CreateGisMaps < ActiveRecord::Migration[5.0]
  def change
    create_table :gis_maps do |t|
      t.belongs_to :concept
      t.belongs_to :content
      t.string     :state
      t.string     :title
      t.string     :name
      t.text       :body
      t.text       :message
      t.string     :tumbnail_file
      t.string     :icon_file
      t.integer    :sort_no
      t.string     :control_password
      t.string     :password_salt
      t.timestamp :recognized_at
      t.timestamp :published_at
      t.timestamps
    end
  end
end
