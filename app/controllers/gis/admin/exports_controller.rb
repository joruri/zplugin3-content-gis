require 'csv'
class Gis::Admin::ExportsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Gis::Content::Entry.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    if params[:do] == 'export'

      @db = params[:item][:db_id].present? ? @content.form_dbs.find_by(id: params[:item][:db_id]) : nil

      entries = Gis::EntriesFinder
        .new(@content.entries, user: Core.user, content: @content)
        .search(entry_criteria)

      entries = entries.where(entries.arel_table[:db_id].eq(@db.try(:id)))
      entries = entries.order(:id)

      bom = %w(EF BB BF).map { |e| e.hex.chr }.join

      data = CSV.generate(bom, force_quotes: true) do |csv|
        columns = [ "ID", "状態", "削除" ]
        if @db.present?
          db_items = @db.items.public_state
          db_items.each do |item|
          case item.item_type
          when 'office_hours'
            8.times do |i|
              w = Webdb::Entry::WEEKDAY_OPTIONS[i]
              columns << "#{item.title}_#{w}_午前_開始"
              columns << "#{item.title}_#{w}_午前_終了"
              columns << "#{item.title}_#{w}_午後_開始"
              columns << "#{item.title}_#{w}_午後_終了"
            end
              columns << "#{item.title}_備考"
            else
              columns << item.title
            end
          end
          columns += ["カテゴリ", "緯度", "経度"]
        else
          columns += ["タイトル", "カテゴリ", "緯度", "経度"]
        end
        csv << columns

        entries.each do |entry|
          item_array = [entry.id, entry.state_text, nil]
          if @db.present?
            files = entry.files
            db_items.each do |item|
              case item.item_type
              when 'office_hours'
                Webdb::Entry::WEEKDAY_OPTIONS.each_with_index do |w, i|
                  item_array << entry.item_values.dig(item.name, 'open', i.to_s)
                  item_array << entry.item_values.dig(item.name, 'close', i.to_s)
                  item_array << entry.item_values.dig(item.name, 'open2', i.to_s)
                  item_array << entry.item_values.dig(item.name, 'close2', i.to_s)
                end
                item_array << entry.item_values.dig(item.name, 'remark')
              when 'ampm', 'blank_weekday'
                item_array << entry.item_values.dig(item.name, 'text')
              when 'check_data'
                val = []
                if entry.item_values[item.name].present? && entry.item_values[item.name].kind_of?(Hash)
                  checks = entry.item_values.dig(item.name, 'check')
                  select_data = item.item_options_for_select_data
                  if select_data.present? && checks.present?
                    select_data.each{|e| val << e[0] if checks.include?(e[1].to_s) }
                  end
                end
                item_array << val.join("，")
              when 'check_box'
                val = []
                if entry.item_values[item.name].present? && entry.item_values[item.name].kind_of?(Hash)
                  checks = entry.item_values.dig(item.name, 'check')
                  select_data = item.item_options_for_select
                  if select_data.present? && checks.present?
                    select_data.each{|e| val << e[0] if checks.include?(e[1]) }
                  end
                end
                item_array << val.join("，")
              when 'select_data', 'radio_data'
                val = ""
                if select_data = item.item_options_for_select_data
                  select_data.each{|e| val = e[0] if e[1] == entry.item_values[item.name].to_i }
                end
                item_array << val
              else
                item_array << entry.item_values[item.name]
              end
            end
          else
            item_array << entry.title
          end
          item_array << entry.categories.map(&:title).join(', ')
          if entry.lat.blank? || entry.lng.blank?
            item_array << entry.geom.try(:as_text)
          else
            item_array += [ entry.lat, entry.lng ]
          end
          csv << item_array
        end
      end
      return send_data data, type: 'text/csv', filename: "#{@content.name}_データ一覧_#{Time.now.to_i}.csv"
    end

  end

  private

  def entry_criteria
    params[:criteria] ? params[:criteria].to_unsafe_h : {}
  end

end
