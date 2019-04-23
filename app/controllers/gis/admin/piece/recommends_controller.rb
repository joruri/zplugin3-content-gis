class Gis::Admin::Piece::RecommendsController < Cms::Admin::Piece::BaseController

  def update
    item_in_settings = (params[:item][:in_settings] || {})
    recommend_ids = params[:item][:in_recommend_ids].blank? ? [] : params[:item][:in_recommend_ids]
    recommend_ids = recommend_ids.select(&:present?).map(&:to_i).uniq
    item_in_settings[:in_recommend_ids] = YAML.dump(recommend_ids)
    params[:item][:in_settings] = item_in_settings
    super
  end

  def base_params_item_in_settings
    [:in_recommend_ids]
  end
end
