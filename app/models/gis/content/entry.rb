class Gis::Content::Entry < Cms::Content
  default_scope { where(model: 'Gis::Entry') }

  STATE_OPTIONS = [['下書き保存', 'draft'], ['承認依頼', 'approvable'], ['即時公開', 'public']]
  LIMIT_OPTIONS = [['10件', '10'], ['20件', '20'], ['30件', '30'], ['50件', '50'], ['100件', '100']]
  has_many :settings, foreign_key: :content_id, class_name: 'Gis::Content::Setting', dependent: :destroy
  has_many :entries, foreign_key: :content_id, class_name: 'Gis::Entry', dependent: :destroy
  has_many :root_categories, -> { with_root },
                             foreign_key: :content_id, class_name: 'Gis::Category', dependent: :destroy
  has_many :categories, foreign_key: :content_id, class_name: 'Gis::Category', dependent: :destroy
  has_many :layers, foreign_key: :content_id, class_name: 'Gis::Layer', dependent: :destroy
  has_many :portal_maps, foreign_key: :content_id, class_name: 'Gis::Map', dependent: :destroy
  has_many :registrations, foreign_key: :content_id, class_name: 'Gis::Registration', dependent: :destroy
  has_many :imports, foreign_key: :content_id, class_name: 'Gis::Entry::Import', dependent: :destroy
  has_many :recommends, foreign_key: :content_id, class_name: 'Gis::Recommend', dependent: :destroy
  has_many :geocodings, foreign_key: :content_id, class_name: 'Gis::GeocodingEntry', dependent: :destroy


  # node
  has_one :node, -> { where(model: 'Gis::Entry').order(:id) },
                 foreign_key: :content_id, class_name: 'Cms::Node'
  has_one :public_node, -> { public_state.where(model: 'Gis::Entry').order(:id) },
                        foreign_key: :content_id, class_name: 'Cms::Node'
  has_one :public_portal_node, -> { public_state.where(model: 'Gis::Portal').order(:id) },
                        foreign_key: :content_id, class_name: 'Cms::Node'
  has_one :public_search_entries_node, -> { public_state.where(model: 'Gis::SearchEntry').order(:id) },
                                    foreign_key: :content_id, class_name: 'Cms::Node'
  has_one :public_registrations_node, -> { public_state.where(model: 'Gis::Registration').order(:id) },
                                    foreign_key: :content_id, class_name: 'Cms::Node'
  has_one :public_change_requests_node, -> { public_state.where(model: 'Gis::ChangeRequest').order(:id) },
                                    foreign_key: :content_id, class_name: 'Cms::Node'

  def save_button_states
    setting_value(:save_button_states) || []
  end

  def submit_state_options(user)
    options = STATE_OPTIONS.clone
    options.reject! { |o| o.last == 'public' } if !user.has_auth?(:manager) && !save_button_states.include?('public')
    options.reject! { |o| o.last == 'approvable' } unless approval_related?
    options
  end

  def public_path
    site.public_path
  end

  def display_limit
    setting_value(:display_limit)
  end

  def map_coordinate
    setting_value(:map_lat_lng)
  end

  def map_default_zoom
    setting_extra_value(:map_lat_lng, :zoom)
  end

  def inquiry_related?
    setting_value(:inquiry_setting) == 'enabled'
  end

  def inquiry_extra_values
    setting_extra_values(:inquiry_setting) || {}
  end

  def inquiry_default_state
    inquiry_extra_values[:state]
  end

  def inquiry_title
    inquiry_extra_values[:inquiry_title]
  end

  def inquiry_style
    inquiry_extra_values[:inquiry_style]
  end

  def recommends_for_option
    recommends.map {|ct| [ct.title, ct.id] }
  end

  def form_dbs
    return Webdb::Db.none if setting_value(:webdb_content_db_id).blank?
    Webdb::Db.where(id: setting_extra_value(:webdb_content_db_id, :db_ids))
  end

  def form_db_options
    return [] if form_dbs.blank?
    form_dbs.map {|t| [t.title, t.id] }
  end

  def form_db_available?
    webdb_content_db.present? && form_dbs.present?
  end

  def webdb_content_db
    return nil if setting_value(:webdb_content_db_id).blank?
    Webdb::Content::Db.where(id: setting_value(:webdb_content_db_id)).first
  end

  def window_text
    setting_extra_values(:webdb_content_db_id)[:window_text].to_s rescue nil
  end

  def form_dbs
    return Webdb::Db.none if setting_value(:webdb_content_db_id).blank?
    Webdb::Db.where(id: setting_extra_value(:webdb_content_db_id, :db_ids))
  end

  def form_default_value
    return {} if setting_extra_value(:webdb_content_db_id, :default_value).blank?
    default_values = {}
    setting_extra_value(:webdb_content_db_id, :default_value).map do | d |
      default_values[d[:name]] = d[:data]
    end
    default_values
  end

  def form_blank_value
    return [] if setting_extra_value(:webdb_content_db_id, :blank_value).blank?
    setting_extra_value(:webdb_content_db_id, :blank_value).split(/,/)
  end

  def form_skip_fields
    return [] if form_default_value.blank?
    form_default_value.keys
  end

  def default_db
    return nil if setting_value(:webdb_content_db_id).blank?
    Webdb::Db.where(id: setting_extra_value(:webdb_content_db_id, :default_db_id)).first
  end

  def registration_db
    return nil if setting_value(:webdb_content_db_id).blank?
    Webdb::Db.where(id: setting_extra_value(:webdb_content_db_id, :registration_db_id)).first
  end

  def geocoding_column
    return nil if setting_value(:webdb_content_db_id).blank?
    setting_extra_value(:webdb_content_db_id, :geocoding_column).to_s
  end

  def approval_content_approval_flow
    Approval::Content::ApprovalFlow.find_by(id: setting_extra_value(:approval_relation, :approval_content_id))
  end

  def approval_related?
    setting_value(:approval_relation) == 'enabled'
  end

  def publish_after_approved?
    setting_extra_value(:approval_relation, :publish_after_approved) == 'enabled'
  end

  def layers_for_option
    layers.map {|c| [c.title, c.id] }
  end

  def root_categories_for_option
    root_categories.map {|c| [c.title, c.id] }
  end

  def categories_for_option
    categories.to_tree.flat_map(&:descendants).map { |c| [c.tree_title, c.id] }
  end

  def mail_from
    setting_value(:mail_from).to_s
  end

  def mail_to
    setting_value(:mail_to).to_s
  end

  def auto_reply?
    setting_value(:auto_reply).to_s == 'send'
  end

  def upper_reply_text
    setting_extra_values(:auto_reply)[:upper_reply_text].to_s rescue nil
  end

  def lower_reply_text
    setting_extra_values(:auto_reply)[:lower_reply_text].to_s rescue nil
  end

  def form_message_text
    setting_value(:form_message).to_s
  end

  def finish_message_text
    setting_value(:finish_message).to_s
  end

  def use_captcha?
    setting_value(:captcha) == 'enabled'
  end

  def contributor
    Sys::User.find_by(id: setting_value(:contributor).to_i)
  end

end
