class Gis::Admin::RecommendsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Gis::Content::Entry.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    if params[:options]
      render 'index_options', layout: false
    else
      @items = @content.recommends
      @items = @items.order(:sort_no)
      @items = @items.paginate(page: params[:page], per_page: params[:limit])
      _index @items
    end
  end

  def show
    @item = @content.recommends.find(params[:id])
    _show @item
  end

  def new
    @item = @content.recommends.build(state: 'public')
    if @content.default_db
      @item.db_id = @content.default_db.id
    end
  end

  def create
    @item = @content.recommends.build(recommend_params)
    _create @item
  end

  def edit
    @item = @content.recommends.find(params[:id])
  end

  def update
    @item = @content.recommends.find(params[:id])
    @item.attributes = recommend_params
    _update @item
  end

  def destroy
    @item = @content.recommends.find(params[:id])
    _destroy @item
  end

  private

  def recommend_params
    params.require(:item).permit(
      :title, :body,:state, :name, :db_id, :sort_no, :operator_type, :body, :icon_uri,
      :in_category_ids => [],
      :creator_attributes => [:id, :group_id, :user_id]
    ).tap do |whitelisted|
      [:item_values].each do |key|
        whitelisted[key] = params[:item][key].to_unsafe_h if params[:item][key]
      end
    end
  end


end
