require 'open-uri'
class Gis::GeocodeJob < ApplicationJob

  def perform(item_id)
    geocoding_request = Gis::GeocodingEntry.find_by(id: item_id)
    return false if geocoding_request.blank?
    address = geocoding_request.address
    result = geocoding_request.geocode
    geocoding_request.set_latlng if geocoding_request.save
  end

end
