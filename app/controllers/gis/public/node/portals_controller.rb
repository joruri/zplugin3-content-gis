require 'rgeo'
require 'rgeo-geojson'
class Gis::Public::Node::PortalsController < Gis::Public::NodeController
  include Gis::Controller::Geocode

  skip_after_action :render_public_layout,
     :only => [:layer, :map, :file_content, :qrcode, :leyer_file_content, :detail, :geocode]

  def show
    @portal = @content.portal_maps.public_state.find_by(name: params[:name])
    return http_error(404) unless @portal
    Page.current_item = @portal
    @folders = @portal.folders.public_state
  end

  def map
    @portal = @content.portal_maps.public_state.find_by(name: params[:name])
    return http_error(404) unless @portal
    Page.title = @portal.title
    @folders = @portal.folders.public_state
  end

  def file_content
    @portal = @content.portal_maps.public_state.find_by(name: params[:name])
    return http_error(404) unless @portal
    params[:file] = File.basename(params[:path])
    params[:type] = :thumb if params[:path] =~ /(\/|^)thumb\//

    file = @portal.files.find_by!(name: "#{params[:file]}.#{params[:format]}")
    send_file file.upload_path(type: params[:type]), filename: file.name
  end

  def layer
    @layer = @content.layers.public_state.find_by(name: params[:layer_id])
    return http_error(404) unless @layer
    @entries = @content.entries.public_state
    @entries = Gis::EntriesFinder.new(@entries, content: @content)
      .public_search(@layer.item_criteria, nil, nil, @layer.db, :and)
    @items = Gis::GeoJsonRenderService.new(@entries).write_features
  end

  def leyer_file_content
    @entry = @content.layers.public_state.find_by(id: params[:layer_id])
    params[:file] = File.basename(params[:path])
    params[:type] = :thumb if params[:path] =~ /(\/|^)thumb\//

    file = @entry.files.find_by!(name: "#{params[:file]}.#{params[:format]}")
    send_file file.upload_path(type: params[:type]), filename: file.name
  end

end