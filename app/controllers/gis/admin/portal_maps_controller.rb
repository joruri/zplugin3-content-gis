class Gis::Admin::PortalMapsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Approval::Controller::Admin::Approval

  def pre_dispatch
    @content = Gis::Content::Entry.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    @items = @content.portal_maps
    @items = @items.paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = @content.portal_maps.find(params[:id])
    _show @item
  end

  def new
    @item = @content.portal_maps.build(state: 'public')
  end

  def create
    @item = @content.portal_maps.build(portal_map_params)
    new_state = params.keys.detect{|k| k =~ /^commit_/ }.try(:sub, /^commit_/, '')
    @item.state = new_state if new_state.present?

    _create @item do
      if @item.state_approvable?
        send_approval_request_mail(@item)
      elsif @item.state_public?
        publish_by_update(@item)
      end
    end
  end

  def update
    @item = @content.portal_maps.find(params[:id])
    @item.attributes = portal_map_params
    new_state = params.keys.detect{|k| k =~ /^commit_/ }.try(:sub, /^commit_/, '')
    @item.state = new_state if new_state.present?

    _update @item do
      if @item.state_approvable?
        send_approval_request_mail(@item)
      end
    end
  end

  def destroy
    @item = @content.entportal_mapsries.find(params[:id])
    _destroy @item
  end

  def publish
    @item = @content.portal_maps.find(params[:id])
    _publish(@item)
  end

  def approve
    @item = @content.portal_maps.find(params[:id])
    _approve(@item)
  end

  def passback
    @item = @content.entries.find(params[:id])
    _passback @item
  end

  def pullback
    @item = @content.entries.find(params[:id])
    _pullback @item
  end

  def destroy
    @item = @content.portal_maps.find(params[:id])
    _destroy @item
  end

  private

  def portal_map_params
    params.require(:item).permit(
      :title, :body,:state, :name, :message, :tumbnail_file, :icon_file, :in_tmp_id,
      :in_category_ids => [],
      :creator_attributes => [:id, :group_id, :user_id],
      :editable_groups_attributes => [:id, :group_id],
      :in_approval_flow_ids => [],
      :inquiries_attributes => [:id, :state, :group_id, :_destroy]
    )
  end


end
