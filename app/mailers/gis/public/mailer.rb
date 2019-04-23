class Gis::Public::Mailer < ApplicationMailer
  def request_receipt(form_request:, from:, to:)
    raise ArgumentError.new("emails required. (from: #{from}, to: #{to})") if from.to_s.blank? || to.to_s.blank?

    @content = form_request.content
    @form_request = form_request

    if entry = @form_request.entry
      title_item = entry.db.present? ? entry.db.items.public_state.first : nil
      @title = @form_request.item_values.dig(title_item.name) if title_item
    end
    mail from: from, to: to, subject: "#{@content.name}（#{@content.site.name}）：登録申請メール"
  end

  def request_auto_reply(form_request:, from:, to:)
    raise ArgumentError.new("emails required. (from: #{from}, to: #{to})") if from.to_s.blank? || to.to_s.blank?

    @content = form_request.content
    @form_request = form_request

    mail from: from, to: to, subject: "#{@content.name}（#{@content.site.name}）：受信確認自動返信メール"
  end
end
