class Gis::Admin::Layers::DrawSettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Gis::Content::Entry.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @layer = @content.layers.find(params[:layer_id])
    return http_error(404) unless @layer
  end

  def index
    @items = @layer.draw_settings.order(:updated_at)
      .paginate(page: params[:page], per_page: params[:limit])

    @item = @items.first
    _index @items
  end

  def show
    @item = @layer.draw_settings.first
    return http_error(404) if @item.blank?
    _show @item
  end

  def new
    new_config = {
      :layer_id => @layer.id, :label_color => "rgb(0, 0, 0)",:point_color=>"rgb(0, 0, 0)",
      :line_color => "rgb(0, 0, 0)",:polygon_color=>"rgb(0, 0, 0)", :label_size => 8
      }
    @item = @layer.draw_settings.first || @layer.draw_settings.build
    #@show_config =
    @item.geometry_type = @layer.geometry_type if @item.geometry_type.blank?
  end

  def edit
    @item = @layer.draw_settings.first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @layer.editable?
  end

  def create
    @item = @layer.draw_settings.build
    @item.attributes = legend_params
    @item.layer_id = @layer.id
     _create @item
  end

  def update
    @item = @layer.draw_settings.find_by(id: params[:id])
    return http_error(404) if @item.blank?
    @item.attributes = legend_params
     _update @item
  end

private

  def legend_params
    params.require(:item).permit(:geometry_type, :label_column, :label_color, :label_position,
      :label_size, :point_color, :point_fill, :line_color, :line_fill, :line_width,
      :polygon_color,:polygon_fill)
  end

end
