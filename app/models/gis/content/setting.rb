class Gis::Content::Setting < Cms::ContentSetting
  set_config :allowed_attachment_type, menu: :form,
    name: '添付ファイル/許可する種類',
    style: 'width: 500px;',
    comment: '例: gif,jpg,png,pdf,doc,docx,xls,xlsx,ppt,pptx,odt,ods,odp',
    default_value: ''
  set_config :attachment_thumbnail_size, menu: :form,
    name: "添付ファイル/サムネイルサイズ",
    style: 'width: 100px;',
    comment: '例: 120x90',
    default_value: '120x90'
  set_config :save_button_states, menu: :form,
    name: '即時公開ボタン',
    form_type: :check_boxes,
    options: Gis::Content::Entry::STATE_OPTIONS.reject { |o| o.last != 'public' },
    default_value: ['public']
  set_config :map_lat_lng, menu: :form,
    name: "地図中心座標",
    style: 'width: 500px;',
    comment: '例: 35.702708,139.560831',
    extra_options: {
      zoom: [
              ["1/500000000", 0], ["1/250000000", 1], ["1/120000000", 2], ["1/60000000", 3],
              ["1/30000000", 4], ["1/1,5000000", 5], ["1/7500000", 6],
              ["1/3800000", 7], ["1/1800000", 8], ["1/1000000", 9],
              ["1/500000", 10], ["1/200000", 11], ["1/100000", 12],
              ["1/50000", 13], ["1/30000", 14], ["1/15000", 15],
              ["1/7500", 16], ["1/3500", 17], ["1/1800", 18]
            ]
    },
    default_value: '',
    default_extra_values: {
      zoom: 14
    }

  set_config :inquiry_setting, menu: :form,
    name: '連絡先',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    extra_options: {
      default_state_options: [['表示', 'visible'], ['非表示', 'hidden']],
    },
    default_value: 'enabled',
    default_extra_values: {
      state: 'hidden',
      inquiry_title: 'お問い合わせ',
      inquiry_style: '@name@@address@@tel@@fax@@email_link@'
    }

  set_config :display_limit, menu: :index,
    name: '一覧表示件数',
    default_value: 30

  set_config :basic_setting, menu: :page,
    name: '詳細レイアウト設定',
    options: lambda { Core.site.public_concepts_for_option.to_a },
    lower_text: "未設定の場合、検索結果一覧ディレクトリの設定が記事へ反映されます",
    default_extra_values: {
      default_layout_id: nil
    }

  set_config :portal_basic_setting, menu: :page,
    name: '個別地図レイアウト設定',
    options: lambda { Core.site.public_concepts_for_option.to_a },
    lower_text: "未設定の場合、個別地図ポータルディレクトリの設定が記事へ反映されます",
    default_extra_values: {
      default_portal_layout_id: nil
    }

  set_config :approval_relation, menu: :relation,
    name: '承認フロー',
    form_type: :radio_buttons,
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    extra_options: {
      publish_after_approved_options: [['使用する', 'enabled'], ['使用しない', 'disabled']]
    },
    default_value: 'disabled',
    default_extra_values: {
      approval_content_id: nil,
      publish_after_approved: 'disabled'
    }


  set_config :webdb_content_db_id, menu: :relation,
    name: 'データベース',
    options: lambda { Webdb::Content::Db.where(site_id: Core.site.id).map { |ct| [ct.name, ct.id] } },
    default_extra_values: {
      db_ids: [],
      default_db_id: nil,
      registration_db_id: nil,
      window_text: nil,
      geocoding_column: nil,
      default_value: nil,
      blank_value: nil
    }

  set_config :mail_from, menu: :request,
    name: '差出人メールアドレス'
  set_config :mail_to, menu: :request,
    name: '通知先メールアドレス'

  set_config :form_message, menu: :request,
    name: '申請フォーム文言',
    form_type: :text_area

  set_config :finish_message, menu: :request,
    name: '申請登録後メッセージ',
    form_type: :text_area

  set_config :captcha, menu: :request,
    name: '画像認証',
    options: [['使用する', 'enabled'], ['使用しない', 'disabled']],
    default_value: 'disabled'

  def value_name
    case name
    when 'basic_setting'
      Cms::Layout.find_by(id: default_layout_id).try!(:concept_name_and_title)
    when 'portal_basic_setting'
      Cms::Layout.find_by(id: default_portal_layout_id).try!(:concept_name_and_title)
    when 'contributor'
      Sys::User.find_by(id: value).try!(:name)
    else
      super
    end
  end

  def extra_values=(params)
    ex = extra_values
    case name
    when 'map_lat_lng'
      ex[:zoom] = params[:zoom]
    when 'webdb_content_db_id'
      ex[:db_ids] = params[:db_ids].to_a.map(&:to_i)
      ex[:default_db_id]       = params[:default_db_id].to_i
      ex[:registration_db_id]  = params[:registration_db_id].to_i
      ex[:window_text]         = params[:window_text]
      ex[:geocoding_column]    = params[:geocoding_column]
      ex[:default_value]       = params[:default_value]
      ex[:blank_value]         = params[:blank_value]
    when 'approval_relation'
      ex[:approval_content_id] = params[:approval_content_id].to_i
      ex[:publish_after_approved] = params[:publish_after_approved]
    when 'mapserver_relation'
      ex[:url] = params[:url]
    when 'auto_reply'
      ex[:upper_reply_text] = params[:upper_reply_text]
      ex[:lower_reply_text] = params[:lower_reply_text]
    when 'basic_setting'
      ex[:default_layout_id] = params[:default_layout_id].to_i
    when 'portal_basic_setting'
      ex[:default_portal_layout_id] = params[:default_portal_layout_id].to_i
    end
    super(ex)
  end

  def default_layout_id
    extra_values[:default_layout_id] || 0
  end

  def default_portal_layout_id
    extra_values[:default_portal_layout_id] || 0
  end

  def default_values
    extra_values[:default_value].present? ? extra_values[:default_value] : [{name: nil, data: nil}]
  end

private

  def validate_value
    case name
    when 'mail_from', 'mail_to'
      if value.blank?
        errors.add :value, :blank
      elsif value !~ /\A.+@.+\z/
        errors.add :value, :email
      end
    end
  end
end
