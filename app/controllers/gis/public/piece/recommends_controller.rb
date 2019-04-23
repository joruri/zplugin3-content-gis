class Gis::Public::Piece::RecommendsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Gis::Piece::Recommend.find_by(id: Page.current_piece.id)
    return render plain: '' if @piece.blank?
    @content = @piece.content
    return render plain: '' if @content.blank?
  end

  def index
    @items = @piece.recommend_items
  end

end
