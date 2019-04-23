class Gis::Public::Node::ChangeRequestsController < Gis::Public::RegistrationsController

  def index
    @list_style = :list
    if params[:keyword].present?
      @entries = @content.entries.public_state
      item = Gis::EntriesFinder.new(@entries, content: @content)
      @items = item.public_search({}, params[:keyword], nil, @registration_db.try(:id), :and)
    else
      @items = []
    end
  end

  def show
    @target = @content.entries.public_state.find_by(name: params[:name])
    return http_error(404) unless @target
    @list_style =  :list
    @item = @content.registrations.build({
      entry_id: @target.id, item_values: @target.item_values,
      lat: @target.lat, lng: @target.lng, geom: @target.geom,
      in_category_ids: @target.in_category_ids
    })
    if @content.form_blank_value.present?
       @content.form_blank_value.each do |a|
         @item.item_values[a] = nil
       end
    end
  end

  def confirm
    @target = @content.entries.public_state.find_by(name: params[:name])
    return http_error(404) unless @target
    build_registration
    return render :show if @content.use_captcha? && !@item.valid_with_captcha?
    return render :show if !@item.valid?
    return render :show if params[:back]
  end

  def send_request
    @target = @content.entries.public_state.find_by(name: params[:name])
    return http_error(404) unless @target
    build_registration
    @item.entry_id = @target.id
    if params[:edit_answers] || !@item.save
      return render :show
    else
      send_mail_and_redirect_to_finish
    end
  end

end