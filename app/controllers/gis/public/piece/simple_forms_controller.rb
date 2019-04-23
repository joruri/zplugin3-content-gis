class Gis::Public::Piece::SimpleFormsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Gis::Piece::SimpleForm.find_by(id: Page.current_piece.id)
    return render plain: '' if @piece.blank?
    @content = @piece.content
    return render plain: '' if @content.blank?
    @node = @content.public_node
    return render plain: '' if @node.blank?
  end

  def index
    @titles = @piece.titles
    @recommend_ids = @piece.in_recommend_ids
    return render plain: '' if @recommend_ids.blank?
    @recommends = @content.recommends.order(:sort_no)
  end

end
