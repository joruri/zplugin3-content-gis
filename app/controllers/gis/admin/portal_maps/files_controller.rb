class Gis::Admin::PortalMaps::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Gis::Content::Entry.find(params[:content])
    @portal = @content.portal_maps.find(params[:portal_map_id])
  end

  def content
    params[:name] = File.basename(params[:path])
    params[:type] = :thumb if params[:path] =~ /(\/|^)thumb\//

    file = @portal.files.find_by!(name: "#{params[:name]}.#{params[:format]}")
    send_file file.upload_path(type: params[:type]), filename: file.name
  end
end
