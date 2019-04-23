class Gis::Admin::ImportsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Gis::Content::Entry.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    @item = @content.imports.build
  end

  def create
    if params.dig(:item, :file)
      item = @content.imports.build
      item.db_id = params[:item][:db_id]
      item.file = params[:item][:file]
      item.file_type = params[:item][:file_type]
      item.srid = params[:item][:srid]
      if item.file_type == "gxml"
        extras = {}
        extras[:item_id] = extra_params[:item_id]
        item.extras = extras
      end
      if item.save
        flash[:notice] = "データをインポートしました。"
        Gis::ImportEntryJob.perform_now(item.id, item.file_type)
      else
        Rails.logger.debug item.errors.inspect
        flash[:notice] = "ファイルの解析に失敗しました。"
      end
    end
    return redirect_to action: :index
  end

private

  def extra_params
    params.permit(:item_id)
  end

end
