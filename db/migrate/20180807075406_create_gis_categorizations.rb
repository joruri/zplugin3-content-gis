class CreateGisCategorizations < ActiveRecord::Migration[5.0]
  def change
    create_table :gis_categorizations do |t|
      t.integer  :categorizable_id
      t.string   :categorizable_type
      t.integer  :category_id
      t.string   :categorized_as
      t.integer  :sort_no
      t.timestamps
    end
  end
end
