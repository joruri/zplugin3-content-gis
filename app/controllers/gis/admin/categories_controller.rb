class Gis::Admin::CategoriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Gis::Content::Entry.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @parent_category = @content.categories.find_by(id: params[:category_id])
  end

  def index
    if params[:options]
      render 'index_options', layout: false
    else
      @items = if @parent_category
                 @parent_category.children
               else
                 @content.root_categories
               end
      @items = @items.paginate(page: params[:page], per_page: params[:limit])
      _index @items
    end
  end

  def show
    @item = @content.categories.find(params[:id])
    _show @item
  end

  def new
    @item = @content.categories.build(state: 'public', sort_no: 10)
  end

  def create
    @item = @content.categories.build(category_params)
    @item.parent = @parent_category if @parent_category
    _create @item
  end

  def edit
    @item = @content.categories.find(params[:id])
  end

  def update
    @item = @content.categories.find(params[:id])
    @item.attributes = category_params
    _update @item
  end

  def destroy
    @item = @content.categories.find(params[:id])
    _destroy @item
  end

  private

  def category_params
    params.require(:item).permit(
      :description, :name, :sort_no, :state, :title, :icon_uri,
      :creator_attributes => [:id, :group_id, :user_id]
    )
  end
end
