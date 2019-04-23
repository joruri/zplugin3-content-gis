class Gis::Public::Node::EntriesController < Gis::Public::NodeController
  skip_after_action :render_public_layout, :only => [:file_content, :qrcode, :detail]
  before_action :set_translation_condition

  def index
    @list_style = :list
    @entries = @content.entries.public_state
    criteria = entry_criteria
    item = Gis::EntriesFinder.new(@entries, content: @content)
    if params[:recommend].present?
      items = item.recommend_search(params[:recommend])
    else
      items = item.public_search(criteria, keyword, "#{sort_key} #{order_key}", target, :and)
    end
    @markers = items.select(:id, :name, :geometry_type, :lat, :lng, :icon_uri)
    @items = items.paginate(
      page: params[:page],
      per_page: @content.display_limit
    )
    if default_position = @content.map_coordinate
      center_lat  = default_position.split(/,/)[0]
      center_lng  = default_position.split(/,/)[1]
      @items = @items.order(
        Arel.sql("ST_Distance(ST_GeomFromText('POINT(#{center_lng.to_f} #{center_lat.to_f})',4326), gis_entries.geom)")
        )
    end
    @target_db = params[:target].present? ? @content.form_dbs.find_by(id: params[:target]) : @content.default_db
  end

  def show
    @item = public_or_preview_entry(id: params[:id], name: params[:name])
    return http_error(404) unless @item
    Page.title = @item.title if @item.title.present?
    @db = @item.db
    title_item = @db.present? ? @db.items.public_state.first : nil
    Page.title = @item.item_values.dig(title_item.name) if title_item
    Page.current_item = @item
    @list_style = :detail
    @nearby_facilities = nearby_facilities(@item)
    @nearby_markers  = public_or_perview_entries(ids: params[:ids], names: params[:names])
  end


  def file_content
    @entry = @content.entries
    @entry = @entry.public_state unless Core.preview_mode?
    @entry = @entry.find_by(name: params[:name])
    return http_error(404) unless @entry
    params[:file] = File.basename(params[:path])
    params[:type] = :thumb if params[:path] =~ /(\/|^)thumb\//

    file = @entry.files.find_by!(name: "#{params[:file]}.#{params[:format]}")
    send_file file.upload_path(type: params[:type]), filename: file.name
  end

  private

  def entry_criteria
    criteria = params[:criteria] ? params[:criteria].to_unsafe_h : {}
    criteria[:category_ids] = params[:category_ids] if params[:category_ids].present?
    criteria
  end

  def sort_key
    params[:sort] ? params[:sort] : nil
  end

  def order_key
    params[:order] ? params[:order] : 'asc'
  end

  def keyword
    params[:keyword] ? params[:keyword] : nil
  end

  def target
    params[:target] ? params[:target] : nil
  end

  def entry_params
    params.require(:item).permit(:title, :item_values, :in_target_date,
      :maps_attributes => [:id, :name, :title, :map_lat, :map_lng, :map_zoom,
      :markers_attributes => [:id, :name, :lat, :lng]]).tap do |whitelisted|
      whitelisted[:item_values] = params[:item][:item_values].permit! if params[:item][:item_values]
      whitelisted[:in_target_dates] = params[:item][:in_target_dates].permit! if params[:item][:in_target_dates]
    end
  end

  def set_target_date_idx
    @date_idx = 0
  end

  def nearby_facilities(item)
    entries = Gis::Entry.all
    entries = entries.public_state unless Core.preview_mode?
    entries = entries.where!(content_id: @content.id)
    entries = entries.search_nearby(lat: item.lat, lng: item.lng, distance: 1.5, exception: item.id )
    entries = entries.select(:id, :name, :geometry_type, :lat, :lng, :icon_uri)
    entries
  end

end