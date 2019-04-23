class Gis::Admin::LayersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Gis::Content::Entry.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    if params[:options]
      render 'index_options', layout: false
    else
      @items = @content.layers
      @items = @items.paginate(page: params[:page], per_page: params[:limit])
      _index @items
    end
  end

  def show
    @item = @content.layers.find(params[:id])
    _show @item
  end

  def new
    @item = @content.layers.build(state: 'public')
    if @content.default_db
      @item.db_id = @content.default_db.id
    end
  end

  def create
    @item = @content.layers.build(layer_params)
    _create @item
  end

  def edit
    @item = @content.layers.find(params[:id])
  end

  def update
    @item = @content.layers.find(params[:id])
    @item.attributes = layer_params
    _update @item
  end

  def destroy
    @item = @content.layers.find(params[:id])
    _destroy @item
  end

  private

  def layer_params
    params.require(:item).permit(
      :title, :body, :state, :name, :kind, :opacity, :use_slideshow, :geometry_type, :srid,
      :use_export_csv, :use_export_kml, :use_export_kml_no_label, :in_tmp_id, :db_id,
      :in_category_ids => [],
      :creator_attributes => [:id, :group_id, :user_id],
      :editable_groups_attributes => [:id, :group_id],
    ).tap do |whitelisted|
      [:item_values].each do |key|
        whitelisted[key] = params[:item][key].to_unsafe_h if params[:item][key]
      end
    end
  end


end
