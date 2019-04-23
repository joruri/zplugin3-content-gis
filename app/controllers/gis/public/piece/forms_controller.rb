class Gis::Public::Piece::FormsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Gis::Piece::Form.find_by(id: Page.current_piece.id)
    return render plain: '' if @piece.blank?
    @content = @piece.content
    return render plain: '' if @content.blank?
    @db = @piece.target_db
    return render plain: '' if @db.blank?
    @node = @content.public_node
    return render plain: '' if @node.blank?
  end

  def index
    @items = @db.public_items.target_search_state
    @categories = @content.categories.with_root.public_state
  end

end
