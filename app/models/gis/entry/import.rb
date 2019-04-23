require 'rgeo'
require 'rgeo-shapefile'
class Gis::Entry::Import < Gis::Import
  default_scope { where(:import_type => self.name) }

  enum_ish :file_type, [:csv, :csv_zip, :shape, :gxml], default: :csv, predicate: true
  enum_ish :srid, [4326, 4301, 2443, 2444, 2445, 2446, 2447, 2448, 2449, 2450, 2452, 2453, 2454, 2455, 2456, 2457, 2458, 2459, 2460, 2461], default: 4326

  def parse_line(row, i, type)
    entry_attributes = {}
    delete_attributes = {}
    maps_attributes = []
    entry_attributes['db_id'] = db.try(:id)
    json_attributes = {}
    category_attributes = []
    upload_files = []
    fields = nil
    case type
    when :shape
      fields = row.attributes
      entry = content.entries.build
      entry_attributes['state'] = 'public'
      json_attributes = generate_json_attributes(row.attributes)
      entry_attributes['title'] = row.attributes['タイトル']
      entry_attributes['body'] = row.attributes['説明']
      entry_attributes['geom_text'] = row.geometry.as_text
    when :gxml
      fields = row.values
      entry = content.entries.build
      entry_attributes['state'] = 'public'
      json_attributes = generate_json_attributes(row)
      entry_attributes['geom_text'] = row['geom_text']
    else
      fields = row.fields
      entry = content.entries.where(id: row['ID']).first || content.entries.new
      json_attributes = generate_json_attributes(row)
      entry_attributes['id']    = row['ID']
      entry_attributes['state'] = state_to_status(entry, row['状態'])
      delete_attributes['delete'] = row['削除']
      entry_attributes['title'] = row['タイトル']
      entry_attributes['body'] = row['説明']
      if row['緯度'] && row['経度']
        entry_attributes['lat'] = row['緯度'].to_f
        entry_attributes['lng'] = row['経度'].to_f
      end
      upload_files = get_files(row)
      category_attributes = get_category(row['カテゴリ'])
    end
    line = import_lines.build(:line_no => i+2, :data => fields, :data_type => 'Gis::Entry')

    in_target_dates = {}
    extra_attributes = {srid: srid}
    date_idx = 0
    entry_attributes[:json_values] = json_attributes

    entry_attributes.each do |key , value|
      next if key == :id || key == :json_values || key == 'geom_text'
      entry[key] = value
    end
    Rails.logger.debug "entry_attributes#{entry_attributes.inspect}"
    entry.validate
    line.data_attributes = {
      entry_attributes: entry_attributes,
      date_attributes: in_target_dates,
      delete_attributes: delete_attributes,
      extra_attributes: extra_attributes,
      upload_files: upload_files,
      category_attributes: category_attributes
    }
    line.data_invalid = entry.errors.blank? ? 0 : 1
    line.data_errors = entry.errors.full_messages.to_a if entry.errors.present?
    line
  end

  def generate_json_attributes(row)

    return {} if db.blank?
    json_attributes = {}
    db.items.each_with_index do |item, n|
      if row[item.title].blank? && item.item_type != 'office_hours'
        json_attributes[item.name] = nil
        next
      end
      case item.item_type
      when 'check_box'
        json_attributes[item.name] = {}
        checks = []
        row[item.title].split(/，/).each_with_index do |w, m|
          checks << w
        end
        json_attributes[item.name]['check'] = checks
      when 'check_data'
        json_attributes[item.name] = {}
        checks = []
        row[item.title].split(/，/).each{|w|
          item.item_options_for_select_data.each{|a| checks << a[1].to_s if a[0] == w}
        }
        json_attributes[item.name]['check'] = checks
      when 'select_data', 'radio_data'
        item.item_options_for_select_data.each{|a| json_attributes[item.name] = a[1] if a[0] == row[item.title] }
      when 'office_hours'
        json_attributes[item.name] = {}
        json_attributes[item.name]['open'] = {}
        json_attributes[item.name]['close'] = {}
        json_attributes[item.name]['open2'] = {}
        json_attributes[item.name]['close2'] = {}
        8.times do |idx|
          w = Webdb::Entry::WEEKDAY_OPTIONS[idx]
          json_attributes[item.name]['open'][idx.to_s]  = row["#{item.title}_#{w}_午前_開始"]
          json_attributes[item.name]['close'][idx.to_s]  = row["#{item.title}_#{w}_午前_終了"]
          json_attributes[item.name]['open2'][idx.to_s]  = row["#{item.title}_#{w}_午後_開始"]
          json_attributes[item.name]['close2'][idx.to_s]  = row["#{item.title}_#{w}_午後_終了"]
        end
        json_attributes[item.name]['remark'] = row["#{item.title}_備考"]
      when 'blank_weekday'
        json_attributes[item.name] = {}
        json_attributes[item.name]['weekday']= {}
        row[item.title].split(/／/).each do |d|
          week = d.gsub(/(.*)：(.*)/, '\1')
          opt = d.gsub(/(.*)：(.*)/, '\2')
          idx = entry.class::WEEKDAY_OPTIONS.index(week)
          next if idx.blank?
          json_attributes[item.name]['weekday'][idx.to_s] = opt
        end
      when 'blank_date'
        row[item.title].split(/／/).each do |d|
          date_val = d.split(/：/)
          in_target_dates[date_idx.to_s] = {
            option_value: date_val[1],
            name: item.name,
            event_date: date_val[0]
          }
          date_idx += 1
        end
      when 'ampm'
        json_attributes[item.name] = {}
        json_attributes[item.name]['am'] = {}
        json_attributes[item.name]['pm'] = {}
        row[item.title].split(/／/).each do |d|
          w = d.scan(/(.*?)(\s|　)午前：(.*?)(\s|　)午後：(.*)/)
          next if w.blank?
          idx = entry.class::WEEKDAY_OPTIONS.index(w[0][0])
          next if idx.blank?
          json_attributes[item.name]['am'][idx.to_s] = w[0][2].present? && w[0][2] == '○'
          json_attributes[item.name]['pm'][idx.to_s] = w[0][4].present? && w[0][4] == '○'
        end
      else
        json_attributes[item.name] = row[item.title]
      end
    end
    return json_attributes
  end

  def state_to_status(entry, state_str)
    entry.class.state_options.each{|a| return a[1] if a[0] == state_str }
    return nil
  end

  def get_category(categories)
    return [] if categories.blank?
    entry_categories = content.categories.where(title: categories.split(/, /))
    entry_categories.present? ? entry_categories.map{|c| c.id } : []
  end

  def get_files(row)
    files = []
    photo_attributes = row.select {|key, val| key.to_s =~ /写真/ }
    return files if photo_attributes.blank?
    photo_attributes.each do |key, val|
      photo = Dir.glob("#{upload_directory}/**/#{val}").first
      files << photo if photo.present?
    end
    files
  end

  def register(line)
    entry_attributes  = line.csv_data_attributes['entry_attributes']
    date_attributes   = line.csv_data_attributes['date_attributes']
    delete_attributes = line.csv_data_attributes['delete_attributes']
    extra_attributes  = line.csv_data_attributes['extra_attributes']
    upload_files      = line.csv_data_attributes['upload_files']
    category_attributes = line.csv_data_attributes['category_attributes']
    entry = content.entries.where(id: entry_attributes['id']).first || content.entries.new
    if entry_attributes['id'].present? && entry.present? &&  delete_attributes['delete'].present?
      entry.destroy if delete_attributes['delete'] == '削除'
    else
      entry.state = entry_attributes['state']
      if json_value = entry_attributes['json_values']
        item_values = entry.item_values.presence || {}
        json_value.each do |key , value|
          item_values[key] = value
        end
        entry.item_values = item_values
      end
      if geom_text = entry_attributes['geom_text']
        entry_attributes['geometry_type'] = case geom_text
          when /POINT/
            "point"
          when /LINE/
            "line"
          when /POLYGON/
            "polygon"
          else
            "point"
          end
      end

      entry_attributes.each do |key , value|
        next if key == 'id' || key == 'json_values' || key == 'geom_text'
        entry[key] = value
      end
      entry.in_category_ids = category_attributes if category_attributes.present?

      entry.save
      if geom_text
        entry.update_column(:geom, RGeo::Cartesian.factory(:srid => extra_attributes['srid'].to_i).parse_wkt(geom_text))
        if geom_text =~ /POINT/
          content.entries.where(id: entry.id).update_all("lng = ST_X(geom)")
          content.entries.where(id: entry.id).update_all("lat = ST_Y(geom)")
        end
      end
      if creator
        entry_creator = entry.build_creator(
          group_id: creator.try(:group).try(:id),
          user_id: creator.try(:user).try(:id)
        )
        entry_creator.save
      end
      if upload_files
        upload_files.each do |file|

          filename = File.basename(file)
          title = File.basename(file, ".*")
          new_file = entry.files.build(name: filename)
          new_file.file = Sys::Lib::File::NoUploadedFile.new(path: file)
          new_file.site_id = entry.content.site_id if entry.content
          new_file.name = filename
          new_file.title = title
          new_file.alt_text = title
          new_file.creator_attributes = entry.creator.attributes.slice('user_id', 'group_id')
          new_file.save
        end
      end
    end
    entry
  end
end
