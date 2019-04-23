class Gis::Admin::EntriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication
  include Approval::Controller::Admin::Approval
  include Gis::Controller::Geocode
  include Gis::Controller::Uploader

  before_action :set_target_date_idx, except: [:index, :show, :destroy]

  def pre_dispatch
    @content = Gis::Content::Entry.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    @items = Gis::EntriesFinder.new(@content.entries, user: Core.user, content: @content)
      .search(entry_criteria)

    @items = @items.paginate(page: params[:page], per_page: params[:limit])
    @items = @items.order(updated_at: :desc)
    @items = @items.target_state(params[:target_state])
    @markers = @items.select(:id, :name, :geometry_type, :lat, :lng, :icon_uri)

    if params[:maps] && params[:maps] == 'true'
      render 'index_maps', layout: 'admin/gis/map'
    else
      _index @items
    end
  end

  def show
    @item = @content.entries.find(params[:id])
    if params[:detail]
      render 'detail', layout: false
    else
      _show @item
    end
  end

  def new
    @item = @content.entries.build
    if @content.default_db
      @item.db_id = @content.default_db.id
    end
  end

  def create
    @item = @content.entries.build(entry_params)
    new_state = params.keys.detect{|k| k =~ /^commit_/ }.try(:sub, /^commit_/, '')
    @item.state = new_state if new_state.present?
    upload_files
    _create @item do
      if @item.state_approvable?
        send_approval_request_mail(@item)
      end
    end
  end

  def update
    @item = @content.entries.find(params[:id])
    @item.attributes = entry_params
    new_state = params.keys.detect{|k| k =~ /^commit_/ }.try(:sub, /^commit_/, '')
    @item.state = new_state if new_state.present?

    @item.set_geometry_from_wkt(params[:geometry]) if params[:geometry].present?
    upload_files
    _update @item do
      if @item.state_approvable?
        send_approval_request_mail(@item)
      elsif @item.public?
        publish_by_update(@item)
      end
    end
  end


  def publish_by_update(item)
    if item.publish
      flash[:notice] = "公開処理が完了しました。"
    else
      flash[:notice] = "公開処理に失敗しました。"
    end
  end

  def destroy
    @item = @content.entries.find(params[:id])
    _destroy @item
  end

  def publish
    @item = @content.entries.find(params[:id])
    _publish(@item)
  end

  def approve
    @item = @content.entries.find(params[:id])
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

  def delete_event
    @item = @content.entries.find(params[:id])
    @event = @item.dates.find_by(id: params[:event_id])
    return http_error(404) unless @event
    if @event.destroy
      render plain: "OK"
    else
      render plain: "NG"
    end
  end

  private

  def entry_criteria
    params[:limit] ||=  '30'
    params[:target_state] = 'all' if params[:target_state].blank?
    criteria = params[:criteria] ? params[:criteria].to_unsafe_h : {}
    criteria
  end

  def set_target_date_idx
    @date_idx = 0
  end

  def entry_params
    params.require(:item).permit(:lat, :lng, :title, :summary, :description, :item_values, :in_tmp_id,
      :db_id, :in_target_dates, :creator_attributes => [:id, :group_id, :user_id],
      :editable_groups_attributes => [:id, :group_id],
      :in_category_ids => [],
      :in_approval_flow_ids => []).tap do |whitelisted|
        [:item_values, :in_target_dates].each do |key|
          whitelisted[key] = params[:item][key].to_unsafe_h if params[:item][key]
        end
      end
  end

end
