class Gis::CacheHtmlJob < ApplicationJob

  def perform
    Gis::Entry.record_timestamps = false
    Gis::Entry.all.each do |e|
      e.save
    end
    Gis::Entry.record_timestamps = false
  end

end
