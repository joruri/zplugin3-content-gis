class Gis::Registration < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept
  include Gis::Model::Rel::Category
  include Sys::Model::Rel::File

  apply_simple_captcha

  attr_accessor :captcha_key, :captcha

  enum_ish :state, [:draft, :public, :closed], predicate: true
  # Content
  belongs_to :content, class_name: 'Gis::Content::Entry', required: true

  # Concept
  belongs_to :concept, foreign_key: :concept_id, class_name: 'Cms::Concept'

  # Entry
  belongs_to :entry, foreign_key: :entry_id, class_name: 'Gis::Entry'

  # Template
  belongs_to :db, class_name: 'Webdb::Db'

  # Attachments
  has_many :attachments, dependent: :destroy

  #validates :contributor, presence: true

  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  #validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, if: :auto_reply?

  after_initialize :set_defaults
  after_save :upload_files
  after_save :fix_filename

  scope :target_state, ->(target){
    case target
    when 'all'
      all
    else
      where(state: target)
    end
  }

  def copyable?
    state.in?(%w(draft public closed)) && editable?
  end

  def publishable?
    state.in?(%w(draft closed)) && editable?
  end

  def closable?
    state.in?(%w(draft public)) && editable?
  end

  def auto_reply?
    content.auto_reply?
  end

  def file_content_uri
    if content.public_node.present? && Core.mode == 'public'
      %Q(#{content.public_registrations_node.public_uri}#{name}/file_contents/)
    else
      %Q(#{content.admin_uri.gsub(/entries/, 'registrations')}/#{id}/file_contents/)
    end
  end

  def upload_attachments=(qa)
    qa.each do |value|
      if (file = value[:file]) && file.respond_to?(:original_filename)  # UploadedFile
        at = attachments.build(registration: self)
        at.name = at.title = file.original_filename
        at.file = file
        at.data = file.read
      elsif value[:name]
        if value[:data].present?
          at = attachments.build(registration: self)
          at.name = Util::File.sanitize_filename(value[:name])
          at.title = value[:name]
          at.file = Sys::Lib::File::NoUploadedFile.new(data: Base64.strict_decode64(value[:data]), filename: at.name)
        end
      end
    end
    qa
  end

  def upload_files
    return if attachments.blank?
    attachments.each do |file|
      filename = ::File.basename(file.title)
      title = ::File.basename(file.title, ".*")
      new_file = self.files.build(name: filename)
      new_file.file = file.file
      new_file.site_id = self.content.site_id if self.content
      new_file.name = filename.gsub(/[\s　]/, '').gsub(/[^0-9a-zA-Z\.\-_\\+@#]/, '')
      new_file.title = file.title.gsub(/[\s　]/, '').gsub(/[^0-9a-zA-Z\.\-_\\+@#]/, '')
      new_file.alt_text = file.title
      new_file.save
    end
  end

  def fix_filename
    return if self.files.blank?
    yaml = YAML.load_file("#{Zplugin3::Content::Webdb::Engine.root}/config/upload_setting.yml") rescue nil
    return if yaml.blank?
    file_conf = yaml["upload_setting"].present? ? yaml["upload_setting"]["filename"] : {}
    if file_conf.present?
      item_values.each do |key, val|
        next unless key.to_s == file_conf['id']
        next if val !~ /#{file_conf['type']}/
        file_title = files.find_by(name: val)
        next if file_title.blank?
        file_title.update_columns(title: file_conf['title'])
      end
    end
  end

  def publish
    self.update_columns(state: 'public')
    new_attributes = self.attributes.except("id", "entry_id", "email",
      "created_at", "updated_at", "recognized_at",
      "contributor", "email", "remote_addr", "user_agent")
    contributor_creator = self.creator
    new_attributes[:state] = 'public'
    if self.entry_id && self.entry
      new_entry = self.content.entries.find_by(id: self.entry_id)
      new_entry.attributes = new_attributes
    else
      new_entry = self.content.entries.build(new_attributes)
    end

    new_entry.in_category_ids = self.in_category_ids
    transaction do
      new_entry.save(validate: false)
      files.each do |f|
        f.duplicate(file_attachable: new_entry)
      end
      self.update_columns(entry_id: new_entry.id)
    end
    return new_entry
  end

  def close
    self.update_columns(state: 'closed')
    if self.entry_id && self.entry
      new_entry = self.content.entries.find_by(id: self.entry_id)
      new_entry.update_columns(state: 'closed')
    end
    return true
  end

private

  def set_defaults
    self.geometry_type ||= 'point'
    self.item_values ||= {} if self.has_attribute?(:item_values)
  end

end
