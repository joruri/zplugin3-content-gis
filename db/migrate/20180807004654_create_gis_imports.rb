class CreateGisImports < ActiveRecord::Migration[5.0]
  def change
    create_table :gis_imports do |t|
      t.belongs_to    :concept
      t.belongs_to    :content
      t.belongs_to    :db
      t.integer       :srid
      t.string        :import_type
      t.string        :file_type
      t.string        :parse_state
      t.timestamp     :parse_start_at
      t.timestamp     :parse_end_at
      t.integer       :parse_total
      t.integer       :parse_success
      t.integer       :parse_failure
      t.string        :register_state
      t.timestamp     :register_start_at
      t.timestamp     :register_end_at
      t.integer       :register_total
      t.integer       :register_success
      t.integer       :register_failure
      t.string        :filename
      t.text          :filedata
      t.jsonb         :extras
      t.timestamps
    end
  end
end
