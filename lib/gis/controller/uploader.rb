module Gis::Controller::Uploader
  extend ActiveSupport::Concern

  def upload_files
    if params[:files].present?
      files = params[:files].presence || []
      names = params[:names].presence.reject(&:blank?) || []
      titles = params[:titles].presence.reject(&:blank?) || []
      files.each_with_index do |file, i|
        item = Sys::File.new(file: files[i], name: names[i], title: titles[i])
        item.site_id = Core.site.id
        if @item.id
          item.file_attachable = @item
        else
          item.tmp_id = @item.in_tmp_id
        end

        if item.creatable? && item.save
          #
        else
          item.errors.full_messages.each { |msg| @item.errors.add(:base, "#{item.name}: #{msg}")}
        end
      end
    end
    if params[:delete_files].present?
      item_values = @item.item_values
      params[:delete_files].each do |key, val|
        next if val.blank?
        next if params[:delete_file_names].blank?
        next if params[:delete_file_names][key].blank?
        next if item_values[key].blank?
        next if item_values[key] != params[:delete_file_names][key]
        item_values[key] = nil
      end
      @item.item_values = item_values
    end
  end

end