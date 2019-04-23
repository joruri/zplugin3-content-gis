class Gis::RequestsScript < ParametersScript
  def pull
    ApplicationRecordSlave.each_slaves do
      s_form_requests = Gis::Slave::Request.date_before(:created_at, 5.minutes.ago)

      ::Script.total s_form_requests.size

      s_form_requests.each do |s_form_request|
        ::Script.progress(s_form_request) do
          pull_requests(s_form_request)
          s_form_request.destroy
        end
      end
    end
  end

  protected

  def pull_requests(s_form_request)
    form_request = Gis::Request.new(s_form_request.attributes.except('id'))
    form_request.save(validate: false)
    send_request_mail(form_request)
  end

  def send_request_mail(form_request)
    content = form_request.content
    Gis::Public::Mailer.request_receipt(form_request: form_request, from: content.mail_from, to: content.mail_to)
                .deliver_now if content.mail_from.present? && content.mail_to.present?
  end
end
