class Gis::Public::Piece::PortalsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = Gis::Piece::Portal.find_by(id: Page.current_piece.id)
    return render plain: '' if @piece.blank?
    @content = @piece.content
    return render plain: '' if @content.blank?
    @node    = @content.public_portal_node
    return render plain: '' if @node.blank?
  end

  def index
    @portal_maps = @content.portal_maps
  end

end
