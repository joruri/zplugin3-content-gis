class Gis::Admin::Content::BaseController < Cms::Admin::Content::BaseController
  layout  'admin/cms'
  def model
    Gis::Content::Entry
  end
end