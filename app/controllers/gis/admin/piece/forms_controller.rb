class Gis::Admin::Piece::FormsController < Cms::Admin::Piece::BaseController

  def base_params_item_in_settings
    [:target_db_id]
  end
end
