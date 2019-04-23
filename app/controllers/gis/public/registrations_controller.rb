class Gis::Public::RegistrationsController < Cms::Controller::Public::Base
  include SimpleCaptcha::ControllerHelpers
  include Gis::Controller::Geocode
  skip_after_action :render_public_layout, :only => [:geocode]

  def pre_dispatch
    @node    = Page.current_node
    @content = ::Gis::Content::Entry.find_by(id: @node.content.id)
    return http_error(404) unless @content
    @node = Page.current_node
    @registration_db = @content.registration_db
  end

  def build_registration
    @item = @content.registrations.build(registration_params)
    @item.concept_id = @content.concept_id
    @item.captcha = params[:captcha]
    @item.captcha_key = params[:captcha_key]
    @item.db_id = @registration_db.try(:id)
    @item.remote_addr = request.remote_ip
    @item.user_agent = request.user_agent
    @item.state = 'draft'
  end

  def registration_params
    params.require(:item).permit(:lat, :lng, :title, :item_values, :in_tmp_id,
      :db_id, :in_target_dates, :captcha_key, :captcha, :entry_id, :email,
      :contributor, :name,
      :creator_attributes => [:id, :group_id, :user_id],
      :editable_groups_attributes => [:id, :group_id],
      :in_category_ids => [],
      :upload_attachments => [%w(file name data)],
      :in_approval_flow_ids => []).tap do |whitelisted|
        [:item_values, :in_target_dates].each do |key|
          whitelisted[key] = params[:item][key].to_unsafe_h if params[:item][key]
        end
      end
  end

  def send_mail_and_redirect_to_finish

    ## send mail to manager
    if @content.mail_from.present? && @content.mail_to.present?
      Gis::Public::Mailer.request_receipt(form_request: @item, from: @content.mail_from, to: @content.mail_to)
                            .deliver_now
    end

    if @item.entry_id.present? && new_entry = @content.entries.public_state.find_by(id: @item.entry_id)
      return redirect_to new_entry.public_uri
    else
      return redirect_to "#{@node.public_uri}finish"
    end
  end


  def finish
    #
  end


end