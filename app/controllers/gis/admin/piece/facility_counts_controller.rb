class Gis::Admin::Piece::FacilityCountsController < Cms::Admin::Piece::BaseController
  def base_params_item_in_settings
    [:target_db_id, :message_text, :unit_text]
  end
end
