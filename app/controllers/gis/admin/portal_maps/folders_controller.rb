class Gis::Admin::PortalMaps::FoldersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Gis::Content::Entry.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @portal_map = @content.portal_maps.find(params[:portal_map_id])
  end

  def index
    @items = @portal_map.folders
    @items = @items.paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = @portal_map.folders.find(params[:id])
    _show @item
  end

  def new
    @item = @portal_map.folders.build(state: 'public')
  end

  def create
    @item = @portal_map.folders.build(folder_params)
    _create @item
  end

  def edit
    @item = @portal_map.folders.find(params[:id])
  end

  def update
    @item = @portal_map.folders.find(params[:id])
    @item.attributes = folder_params
    _update @item
  end

  def destroy
    @item = @portal_map.folders.find(params[:id])
    _destroy @item
  end

  private

  def folder_params
    params.require(:item).permit(
      :title, :body,:state, :name, :message, :sort_no,
      :creator_attributes => [:id, :group_id, :user_id],
      :folder_layers_attributes => [:id, :state, :layer_id, :sort_no, :_destroy, :folder_id]
    )
  end

end
