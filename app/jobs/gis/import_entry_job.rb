require 'csv'
require 'rgeo'
require 'rgeo-shapefile'
class Gis::ImportEntryJob < ApplicationJob

  MAX_LOOP = 1000
  def perform(item_id, file_type)
    csv = Gis::Entry::Import.find_by(id: item_id)
    csv.parse_state = 'progress'
    csv.parse_start_at = Time.now
    csv.parse_success = 0
    csv.parse_failure = 0
    csv.save
    case file_type
    when 'csv'
      perform_csv(csv)
    when 'csv_zip'
      perform_csv(csv)
    when 'shape'
      perform_shapefile(csv)
    when 'gxml'
      perform_gxml(csv)
    end
  end

private

  def perform_csv(csv)
    return nil if csv.filedata.blank?
    rows = CSV.parse(csv.filedata, :headers => true)
    csv.parse_total = rows.size
    rows.each_with_index do |row, i|
      if line = csv.parse_line(row, i, :csv)
        if line.data_invalid == 0
          csv.parse_success += 1
        else
          csv.parse_failure += 1
        end
        csv.save if i%100 == 0
      end
    end
    csv.parse_state = 'finish'
    csv.parse_end_at = Time.now
    csv.save
    register(csv.id)
  end

  def perform_shapefile(csv)
    shapefile = Dir.glob("#{csv.upload_directory}/**/*.shp").first
    return false if shapefile.blank?

    RGeo::Shapefile::Reader.open(shapefile) do |file|
      csv.parse_total = file.num_records
      i = 0
      file.each do |row|
        if line = csv.parse_line(row, i, :shape)
          csv.parse_success += 1
        else
          csv.parse_success += 1
        end
        csv.save if i%100 == 0
      end
      i += 1
      file.rewind
    end
    csv.parse_state = 'finish'
    csv.parse_end_at = Time.now
    csv.save
    register(csv.id)
  end

  def perform_gxml(csv)

    xml = Nokogiri::XML(csv.filedata)
    @count = 0
    xml.xpath("//gml:Curve").each_with_index do |row, i|
      pos = row.xpath("gml:segments/gml:LineStringSegment/gml:posList").try(:text)
      next if pos.blank?
      coordinates = pos.split(/\n|\r\n|\r/)
      poslist = []
      coordinates.each do |coordinate|
        latlng = coordinate.split(/ /)
        next if latlng[1].blank? || latlng[0].blank?
        poslist << "#{latlng[1]} #{latlng[0]}"
      end
      geom = "LINESTRING (#{poslist.join(',')})"
      attributes = { }
      attributes['geom_text'] = geom
      id = row.attribute("id").text
      attributes[csv.extras['item_id']] = id if csv.extras.present? && csv.extras['item_id'].present?
      if line = csv.parse_line(attributes, @count, :gxml)
        csv.parse_success += 1
      else
        csv.parse_success += 1
      end
      csv.save if @count%100 == 0
      @count += 1
    end

    xml.xpath("//gml:Point").each_with_index do |row, i|
      pos = row.xpath("gml:pos").try(:text)
      next if pos.blank?
      coordinates = pos.split(/ /)
      attributes = { }
      geom = "POINT(#{coordinates[1]} #{coordinates[0]})"
      attributes['geom_text'] = geom
      id = row.attribute("id").text
      attributes[csv.extras['item_id']] = id if csv.extras.present? && csv.extras['item_id'].present?
      if line = csv.parse_line(attributes, @count, :gxml)
        csv.parse_success += 1
      else
        csv.parse_success += 1
      end
      csv.save if @count%100 == 0
      @count += 1
    end
    csv.parse_state = 'finish'
    csv.parse_end_at = Time.now
    csv.save
    register(csv.id)
  end

  def register(item_id)
    csv = Gis::Entry::Import.find_by(id: item_id)
    csv.register_state = 'progress'
    csv.register_start_at = Time.now
    csv.register_total = csv.valid_import_lines.count
    csv.register_success = 0
    csv.register_failure = 0
    csv.save
    csv.valid_import_lines.each_with_index do |line, i|
      model = csv.register(line)

      if model && model.errors.size == 0
        csv.register_success += 1
      else
        line.data_errors = model.errors.full_messages.to_a
        csv.register_failure += 1
      end
      csv.save if i%100 == 0
    end

    csv.register_state = 'finish'
    csv.register_end_at = Time.now
    csv.save
  end

end
