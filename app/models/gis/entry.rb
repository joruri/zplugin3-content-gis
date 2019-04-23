class Gis::Entry < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::Editor
  include Sys::Model::Rel::EditableGroup
  include Sys::Model::Rel::File
  include Cms::Model::Rel::Content
  include Cms::Model::Rel::Inquiry
  include Cms::Model::Auth::Concept
  include Sys::Model::Auth::EditableGroup
  include Approval::Model::Rel::Approval
  include Gis::Model::GeometryFactory
  #include Webdb::Model::Rel::Db
  include Sys::Model::Rel::Task
  include Cms::Model::Base::Page::Publisher
  include Gis::Model::Rel::Category
  include Cms::Model::Base::Qrcode

  enum_ish :state, [:draft, :approvable, :approved, :prepared, :public, :closed, :trashed, :archived], predicate: true
  enum_ish :geometry_type, [:point, :line, :polygon, :circle], default: :point, predicate: true

  # Content
  belongs_to :content, class_name: 'Gis::Content::Entry', required: true

  # Page
  belongs_to :concept, foreign_key: :concept_id, class_name: 'Cms::Concept'

  # Template
  belongs_to :db, class_name: 'Webdb::Db'

  scope :public_state, -> { where(state: 'public') }

  scope :search_nearby, ->(lat: nil, lng: nil, distance: nil, exception: nil){
    rel = all
    entry_table = Gis::Entry.arel_table
    rel = rel.where(entry_table[:lat].not_eq(nil).and(entry_table[:lng].not_eq(nil)))
    if lat && lng
      from_origin = distance.present? ? distance * 0.01 : 0.05
      rel = rel.where("ST_Distance(ST_GeomFromText('POINT(#{lng.to_f} #{lat.to_f})',4326), gis_entries.geom) <= #{from_origin}")
    end
    if exception
      rel = rel.where(entry_table[:id].not_eq(exception))
    end
    rel
  }

  scope :select_marker_columns, -> { select(:id, :name, :geometry_type, :lat, :lng) }

  after_initialize :set_defaults
  before_save :set_name
  before_save :set_geometry
  before_save :set_title
  before_save :set_html
  before_save :set_icon_uri

  scope :target_state, ->(target){
    case target
    when 'all'
      all
    else
      where(state: target)
    end
  }

  def layout
    return nil unless layout_id = content.setting_extra_value(:basic_setting, :default_layout_id)
    Cms::Layout.find_by(id: layout_id.to_i)
  end

  def publish(options = {})
    self.state        = 'public'
    self.published_at = Time.now
    return false unless save(validate: false)
    return true
  end

  def close
    self.state        = 'closed'
    self.published_at = nil
    return false unless save(validate: false)
    return true
  end

  def publishable?
    return false unless editable?
    return !public?
  end

  def closable?
    return false unless editable?
    return public?
  end

  def public?
    return state == 'public'
  end

  def set_name
    return if self.name.present?
    date = (created_at || Time.now).strftime('%Y%m%d')
    seq = Util::Sequencer.next_id('gis_entries', version: date, site_id: content.site_id)
    self.name = Util::String::CheckDigit.check(date + format('%04d', seq))
  end

  def public_path
    return '' if public_uri.blank?
    "#{content.public_path}#{public_uri}index.html"
  end

  def public_smart_phone_path
    return '' if public_uri.blank?
    "#{content.public_path}/_smartphone#{public_uri}#{filename_base}.html"
  end

  def set_geometry
    return if self.lng.blank? || self.lat.blank?
    self.geom = wgs84_factory.point(self.lng, self.lat)
  end

  def set_geometry_from_wkt(geom_text)
    self.geom = RGeo::Cartesian.factory(:srid => 4326).parse_wkt(geom_text)
  end

  def file_content_uri
    if content.public_node.present? && public?
      %Q(#{content.public_node.public_uri}#{name}/file_contents/)
    else
      %Q(#{content.admin_uri}/#{id}/file_contents/)
    end
  end

  def category_icon_uri
    return nil if categories.blank?
    return nil unless icon_category = categories.with_icon.first
    icon_category.icon_uri
  end

  def public_uri
    return nil if content.public_node.blank?
    "#{content.public_node.public_uri}#{name}/"
  end

  def preview_uri(terminal: nil, params: {})
    return if (path = public_uri).blank?
    flag = { mobile: 'm', smart_phone: 's' }[terminal]
    query = "?#{params.to_query}" if params.present?
    "#{site.main_admin_uri}_preview/#{format('%04d', site.id)}#{flag}#{path}/preview/#{id}#{query}"
  end

  def file_base_uri
    if state_public? && content.public_node.present?
      public_uri
    else
      admin_uri + '/'
    end
  end

  def change_request_uri
    "#{content.public_change_requests_node.public_uri}/#{name}"
  end

  def google_map_uri
    "https://www.google.com/maps?q=#{lat},#{lng}"
  end

  def navigaton_uri
    "https://www.google.com/maps/dir/?api=1&destination=#{lat},#{lng}"
  end

  def last_updator
    editors.first.try(:user).try(:name) || creator.try(:user).try(:name)
  end

  def last_updated_group
    editors.first.try(:group).try(:name) || creator.try(:user).try(:name)
  end

private

  def set_defaults
    self.geometry_type ||= 'point'
    self.item_values ||= {} if self.has_attribute?(:item_values)
  end

  def set_title
    if db.present?
      self.title = ApplicationController.helpers.entry_title_value(self, self.db, self.files)
    end
  end

  def set_html
    if db.present?
      self.summary = ApplicationController.helpers.entry_body(:list, self.db, self)
    end
  end

  def set_icon_uri
    return if categories.blank?
    return unless icon_category = categories.with_icon.first
    self.icon_uri = icon_category.icon_uri
  end

end
