class Gis::GeocodingEntry < ApplicationRecord
  include Sys::Model::Base
  include Cms::Model::Rel::Content
  include Gis::Model::GeometryFactory

  belongs_to :requestable, polymorphic: true

  def set_latlng
    return if lat.blank? || lng.blank?
    if target = requestable
      target.update_columns(lat: lat)
      target.update_columns(lng: lng)
    end
  end

  def geocode
    require "net/http"
    result = {}
    return result if address.blank?
    url = %Q(http://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi?addr=#{CGI.escape(address)})
    ret = []
    opts = {}
    uri = URI.parse(url)
    res = Net::HTTP.start(uri.host, uri.port) do |http|
      http.get(uri.path + '?'+ uri.query)
    end
    doc = Nokogiri::XML(res.body)
    self.lat = doc.at_xpath('/results/candidate/latitude').text rescue nil
    self.lng = doc.at_xpath('/results/candidate/longitude').text rescue nil
  end

end
