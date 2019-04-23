class Gis::Admin::RegistrationsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Gis::Controller::Geocode
  include Gis::Controller::Uploader

  def pre_dispatch
    @content = Gis::Content::Entry.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    @registration_db = @content.registration_db
  end

  def index
    @items = Gis::EntriesFinder.new(@content.registrations, user: Core.user, content: @content, categorizable_type: 'Gis::Registration')
      .search(entry_criteria)
      .target_state(params[:target_state])

    if params[:csv]
      return export_csv(@items)
    else
      @items = @items.paginate(page: params[:page], per_page: 30).order(updated_at: :desc)
      _index @items
    end
  end

  def show
    @item = @content.registrations.find(params[:id])
    _show @item
  end

  def edit
    @item = @content.registrations.find(params[:id])
  end

  def update
    @item = @content.registrations.find(params[:id])
    @item.attributes = registration_params
    upload_files
    _update @item
  end

  def destroy
    @item = @content.registrations.find(params[:id])
    _destroy @item
  end

  def copy
    @item = @content.registrations.find(params[:id])
    if @item.publish
      entry = @content.entries.find_by(id: @item.entry_id)
      entry.update_columns(state: 'draft') if entry.present?
      @item.update_columns(state: 'draft')
      flash[:notice] = "申請情報を下書き状態でコピーしました。"
    else
      flash[:notice] = "公開に失敗しました。"
    end
    return redirect_to action: :show
  end

  def publish
    @item = @content.registrations.find(params[:id])
    if @item.publish
      flash[:notice] = "申請情報を公開しました。"
    else
      flash[:notice] = "公開に失敗しました。"
    end
    return redirect_to action: :show
  end

  def close
    @item = @content.registrations.find(params[:id])
    if @item.close
      flash[:notice] = "申請情報を非公開にしました。"
    else
      flash[:notice] = "非公開に失敗しました。"
    end
    return redirect_to action: :show
  end


  def export_csv(entries)
    require 'csv'
    bom = %w(EF BB BF).map { |e| e.hex.chr }.join
    data = CSV.generate(bom, force_quotes: true) do |csv|
      csv << [ "状態", "名称", "申請日", "IPアドレス", "ユーザーエージェント" ]
      entries.each do |entry|
        item_array = [entry.state_text]
         if db = entry.db
           if db.items.present? && db.items.first.present?
             item_array << entry.item_values[db.items.first.name]
           else
             item_array << nil
           end
         else
           item_array << entry.title
         end
         item_array << entry.created_at.strftime("%Y-%m-%d %H:%M")
         item_array << entry.remote_addr
         item_array << entry.user_agent
        csv << item_array
      end
    end
    send_data data, type: 'text/csv', filename: "登録・変更申請一覧_#{Time.now.to_i}.csv"
  end

private

  def entry_criteria
    params[:limit] ||=  '30'
    params[:target_state] = 'draft' if params[:target_state].blank?
    criteria = params[:criteria] ? params[:criteria].to_unsafe_h : {}
    criteria
  end

  def registration_params
    params.require(:item).permit(:lat, :lng, :title, :item_values, :in_tmp_id,
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
