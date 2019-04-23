require "uri"
module Gis::MapHelper

  def gis_map_form(form)
    item = form.object || instance_variable_get("@#{form.object_name}")
    render 'gis/admin/_partial/maps/form', f: form, item: item
  end

  def gis_map_view(item)
    render 'gis/admin/_partial/maps/view', item: item
  end

  def gis_public_map_view(item, nearby_markers: [], center: nil)
    render 'gis/public/_partial/maps/view', item: item, nearby_markers: nearby_markers, center: center
  end

  def gmap_view(item, nearby_markers: [], translated: false, center: nil)
    render 'gis/public/_partial/gmaps/view', item: item, nearby_markers: nearby_markers, translated: translated, center: center
  end

  def result_image_tag(item)
    if (file = entry_main_image_file(item))
      image_tag("#{item.file_content_uri}#{url_encode file.name}", alt: file.alt)
    else
      nil
    end
  end

  def search_conditions(content, target)
    content_tag(:div, class: "summary") do
      if params[:recommend].present?
        params[:recommend].each do |key, val|
          ids = content.recommends.where(id: val).select(:id, :title).pluck(:title)
          concat content_tag(:div, ids.join(" OR ").html_safe, class: "condition#{key}") if ids.present?
        end
      elsif target = content.form_dbs.find_by(id: target)
        concat content_tag(:div, params[:keyword], class: "conditionKeyWord")
        categories = params[:categories].present? ? content.categories.where(id: params[:categories]).pluck(:title) : []
        concat content_tag(:div, categories.join(" OR "), class: "conditionCategory") if categories.present?
        target.items.public_state.target_search_state.each do |item|
          param = params.dig(:criteria, item.name)
          next if param.blank?
          case item.item_type
          when 'check_data', 'select_data'
            next unless param.kind_of?(Array)
            checks = []
             param.each{|w|
               item.item_options_for_select_data.each{|a| checks << a[0] if a[1] == w.to_i}
             }
             concat content_tag(:div, checks.join(" OR "), class: "condition_#{item.name}")
          else
            if param.kind_of?(Array)
              concat content_tag(:div, param.join(" OR "), class: "condition_#{item.name}")
            else
              concat content_tag(:div, param, class: "condition#{item.name}")
            end
          end
        end
      else
        concat content_tag(:div, params[:keyword], class: "conditionKeyWord")
        categories = params[:categories].present? ? content.categories.where(id: params[:categories]).pluck(:title) : []
        concat content_tag(:div, categories.join(" OR "), class: "conditionCategory") if categories.present?
      end
    end
  end

private

  def entry_main_image_file(item)
    if db = item.db
      db_image_file(item, db)
    else
      item.image_files.first
    end
  end

  def db_image_file(item, db)
    attachment = db.public_items.where(item_type: 'attachment_file').first
    return unless attachment
    item.image_files.detect { |f| f.name == item.item_values[attachment.name] }
  end

end
