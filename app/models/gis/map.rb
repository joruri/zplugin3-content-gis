class Gis::Map < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Sys::Model::Rel::Editor
  include Sys::Model::Rel::EditableGroup
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept
  include Sys::Model::Rel::File
  include Cms::Model::Rel::Inquiry
  include Sys::Model::Auth::EditableGroup
  include Gis::Model::Rel::Category
  include Cms::Model::Base::Qrcode
  include Approval::Model::Rel::Approval

  enum_ish :state, [:draft, :approvable, :approved, :prepared, :public, :closed, :trashed, :archived], predicate: true
  # Content
  belongs_to :content, class_name: 'Gis::Content::Entry', required: true

  # Page
  belongs_to :concept, foreign_key: :concept_id, class_name: 'Cms::Concept'

  has_many :folders, foreign_key: :map_id,  class_name: 'Gis::Folder', dependent: :destroy

  scope :public_state, -> { where(state: 'public') }

  def layout
    return nil unless layout_id = content.setting_extra_value(:portal_basic_setting, :default_portal_layout_id)
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
    return published_at != nil
  end

  def icon_src
    "#{file_content_uri}#{icon_file}"
  end

  def tumbnail_src
    "#{file_content_uri}#{tumbnail_file}"
  end

  def file_content_uri
    if content.public_portal_node.present?
      %Q("#{content.public_portal_node.public_uri}portal/#{name}/file_contents/)
    else
      %Q(#{content.admin_uri}/portal_maps/#{id}/file_contents/)
    end
  end

  def public_uri
    return nil if content.public_portal_node.blank?
    "#{content.public_portal_node.public_uri}/portal/#{name}"
  end


end
