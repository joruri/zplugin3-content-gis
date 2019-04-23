module Gis::Model::GeometryFactory
  extend ActiveSupport::Concern

  def wgs84_factory
    #projection = '<4326> +proj=longlat +datum=WGS84 +no_defs'
    #ret_factory = RGeo::Cartesian.simple_factory(:srid => 4326, :proj4 => projection)
    #return ret_factory
    RGeo::Cartesian.simple_factory(:srid => 4326)
  end

  def wgs84_feauture_factory
    projection = '<4326> +proj=longlat +datum=WGS84 +no_defs'
    #ret_factory = RGeo::Cartesian.simple_factory(:srid => 4326, :proj4 => projection)
    ret_factory = RGeo::Feature::FactoryGenerator.call(:srid => 4326, :proj4 => projection)
    return ret_factory
  end

  def jgd2000_factory
    projection = '<2446> +proj=tmerc +lat_0=33 +lon_0=133.5 +k=0.9999 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs'
    ret_factory = RGeo::Cartesian.simple_factory(:srid => 2446, :proj4 => projection)
    return ret_factory
  end

  def tokyo_factory
    projection = '<4301> +proj=longlat +ellps=bessel +towgs84=-148,507,685,0,0,0,0 +no_defs'
    ret_factory = RGeo::Cartesian.simple_factory(:srid => 4301, :proj4 => projection)
    return ret_factory
  end

  def jgd2000_latlng_factory
    projection = '<4612>  +proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs '
    ret_factory = RGeo::Cartesian.simple_factory(:srid => 4612, :proj4 => projection)
    return ret_factory
  end

  def wgs84_mercator_factory
    projection = "<3857> +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
    ret_factory = RGeo::Cartesian.simple_factory(:srid => 3857, :proj4 => projection)
    return ret_factory
  end

  def wgs_google_factory
    projection = "<900913> +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
    ret_factory = RGeo::Cartesian.simple_factory(:srid => 900913, :proj4 => projection)
    return ret_factory
  end



end