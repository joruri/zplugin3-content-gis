class Gis::Public::Piece::FacilityCountsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Gis::Piece::FacilityCount.find_by(id: Page.current_piece.id)
    return render plain: '' if @piece.blank?
    @content = @piece.content
    return render plain: '' if @content.blank?
  end

  def index
    @db = @piece.target_db
    @count = @content.entries.public_state
    @count = @count.where(db_id: @db.id) if @db.present?
  end

end
