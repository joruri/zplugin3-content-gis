class Gis::Admin::Piece::SimpleFormsController < Cms::Admin::Piece::BaseController

  def update
    item_in_settings = (params[:item][:in_settings] || {})

    titles = {}
    recommend_ids = {}
    in_lower_texts = {}
    params[:in_titles].to_unsafe_h.each_with_index do |(key,val),i|
      titles[i] = val
      recommends = params[:in_recommend_ids][key].present? ? params[:in_recommend_ids][key] : []
      recommend_ids[i] = recommends
      in_lower_texts[i] = params[:in_lower_texts][key].present? ? params[:in_lower_texts][key] : ''
    end
    item_in_settings[:in_titles] = YAML.dump(titles)
    item_in_settings[:in_recommend_ids] = YAML.dump(recommend_ids)
    item_in_settings[:in_lower_texts] = YAML.dump(in_lower_texts)
    params[:item][:in_settings] = item_in_settings
    super
  end

  def base_params_item_in_settings
    [:in_titles, :in_recommend_ids, :in_lower_texts, :upper_text, :lower_text]
  end
end
