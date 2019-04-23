class Gis::Piece::Recommend < Cms::Piece

  default_scope { where(model: 'Gis::Recommend') }

  def content
    Gis::Content::Entry.find(super.id)
  end

  def recommend_items
    content.recommends.where(id: in_recommend_ids).order(:sort_no)
  end

  def in_recommend_ids
    YAML.load(in_settings['in_recommend_ids'].presence || '[]')
  end

end
