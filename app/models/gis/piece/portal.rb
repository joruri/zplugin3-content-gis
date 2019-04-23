class Gis::Piece::Portal < Cms::Piece

  default_scope { where(model: 'Gis::Portal') }

  def content
    Gis::Content::Entry.find(super.id)
  end

end
