$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "zplugin3/content/gis/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "zplugin3-content-gis"
  s.version     = Zplugin3::Content::Gis::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = "https://github.com/joruri/zplugin3-content-gis"
  s.summary     = "Geographic Information System Content for JoruriCMS2017"
  s.description = "Add Geographic Information System to JoruriCMS2017"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails"
  s.add_dependency 'will_paginate'

  s.add_dependency 'delayed_job'
  s.add_dependency 'delayed_job_active_record'
  s.add_dependency 'delayed_job_master'

  s.add_dependency "pg"

  # Use geospatial database
  s.add_dependency 'gdal'
  s.add_dependency 'exifr'
  s.add_dependency 'activerecord-postgis-adapter'
  s.add_dependency 'rgeo-proj4'
  s.add_dependency 'rgeo'
  s.add_dependency 'rgeo-activerecord'
  s.add_dependency 'rgeo-shapefile'
  s.add_dependency 'rgeo-geojson'
  s.add_dependency 'rubyzip'

end
