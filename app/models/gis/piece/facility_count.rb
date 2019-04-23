class Gis::Piece::FacilityCount < Cms::Piece

  default_scope { where(model: 'Gis::FacilityCount') }

  def content
    Gis::Content::Entry.find(super.id)
  end

  def target_db_id
    setting_value(:target_db_id).to_i
  end

  def target_db
    return nil if target_db_id.blank?
    target_dbs.find_by(id: target_db_id)
  end

  def target_dbs
    content.form_dbs
  end

  def target_dbs_for_option
    target_dbs.map {|g| [g.title, g.id] }
  end

  def message_text
    setting_value(:message_text)
  end

  def unit_text
    setting_value(:unit_text)
  end

end
