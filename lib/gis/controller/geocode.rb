module Gis::Controller::Geocode
  extend ActiveSupport::Concern

  def geocode
    if params[:address].present?
      geocode = @content.geocodings.build(address: params[:address])
      geocode.geocode
      Rails.logger.debug geocode.inspect
      return render json: geocode.to_json
    else
      return http_error(404)
    end
  end

end