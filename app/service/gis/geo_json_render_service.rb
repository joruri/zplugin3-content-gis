require 'rgeo'
require 'rgeo-geojson'
class Gis::GeoJsonRenderService < ApplicationService
  def initialize(entries)
    @entries = entries
  end

  def write_features
    items = []
    @entries.each do |entry|
      feature = RGeo::GeoJSON.encode(entry.geom)
      items << {
        feature: feature,
        entry: entry
      }
    end
    items
  end

end
