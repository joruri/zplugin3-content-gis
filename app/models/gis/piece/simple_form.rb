class Gis::Piece::SimpleForm < Cms::Piece

  default_scope { where(model: 'Gis::SimpleForm') }

  def content
    Gis::Content::Entry.find(super.id)
  end

  def titles
    YAML.load(in_settings['in_titles'].presence || '{}')
  end

  def in_recommend_ids
    YAML.load(in_settings['in_recommend_ids'].presence || '{}')
  end

  def in_lower_texts
    YAML.load(in_settings['in_lower_texts'].presence || '{}')
  end

  def upper_text
    setting_value(:upper_text)
  end

  def lower_text
    setting_value(:lower_text)
  end


end
