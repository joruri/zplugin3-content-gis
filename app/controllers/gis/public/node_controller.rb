class Gis::Public::NodeController < Cms::Controller::Public::Base

  def pre_dispatch
    @node    = Page.current_node
    @content = ::Gis::Content::Entry.find_by(id: @node.content.id)
    return http_error(404) unless @content
    @node = Page.current_node
  end

  def detail
    @item = public_or_preview_entry(id: params[:id], name: params[:name])
    return http_error(404) unless @item
    @db = @item.db
    @nearby_markers  = public_or_perview_entries(ids: params[:ids], names: params[:names])
  end

  def public_or_preview_entry(id: nil, name: nil)
    entries = Gis::Entry.all
    entries = entries.public_state unless Core.preview_mode?
    entries.where!(content_id: @content.id)

    if id
      entries.find_by!(id: id)
    elsif name
      entries.order(:id).find_by!(name: name)
    else
      entries.none
    end
  end

  def public_or_perview_entries(ids: [], names: [])
    entries = Gis::Entry.all
    entries = entries.public_state unless Core.preview_mode?
    entries.where!(content_id: @content.id)

    if ids.present?
      entries.where!(id: ids)
    elsif names.present?
      entries.order(:id).where!(name: names)
    else
      []
    end
  end

  def set_translation_condition
    @translated = cookies[:googtrans].present? ? true : false
    @translated = false if cookies[:googtrans].present? && cookies[:googtrans].to_s == '/ja/ja'
    @lang = cookies[:googtrans].present? ? cookies[:googtrans].to_s.gsub(/\/ja\//, '') : nil
    @lang = "en" if @lang.blank?
  end

end