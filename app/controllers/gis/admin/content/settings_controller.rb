class Gis::Admin::Content::SettingsController < Cms::Admin::Content::SettingsController
  def model
    Gis::Content::Setting
  end
end