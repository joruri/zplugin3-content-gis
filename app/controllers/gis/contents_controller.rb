class Gis::ContentsController < Cms::Controller::Admin::Base
  layout  'admin/cms'

  def pre_dispatch
    return http_error(403) unless Core.user.root?
  end

  def index
    @items = Gis::Content::Entry.paginate(page: params[:page], per_page: 10)
  end

  def install
    Zplugin3::Content::Gis::Engine.install
    return redirect_to zplugin3_content_gis.gis_contents_path, notice: 'インストールしました。'
  end

end
