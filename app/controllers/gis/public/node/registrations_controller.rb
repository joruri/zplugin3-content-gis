class Gis::Public::Node::RegistrationsController < Gis::Public::RegistrationsController

  def index
    @list_style =  :list
    @item = @content.registrations.build
  end

  def confirm
    build_registration
    return render :index if @content.use_captcha? && !@item.valid_with_captcha?
    return render :index if params[:back]
  end

  def send_request
    build_registration
    if params[:edit_answers] || !@item.save
      return render :index
    else
      send_mail_and_redirect_to_finish
    end
  end
end