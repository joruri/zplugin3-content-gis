require 'csv'
class Gis::Import < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator

  attr_accessor :file

  has_many :import_lines, ->{order(:id) }, :dependent => :destroy
  has_many :valid_import_lines, ->{where(data_invalid: 0).order(:id) }, :class_name => 'Gis::ImportLine'
  has_many :invalid_import_lines, ->{where(data_invalid: 1).order(:id) }, :class_name => 'Gis::ImportLine'

  belongs_to :db, :foreign_key => :db_id, :class_name => 'Webdb::Db'
  belongs_to :content, class_name: 'Gis::Content::Entry', required: true

  before_create :set_defaults
  before_validation :set_file_attributes, :on => :create
  after_save :upload_zipfile, :on => :create

  def parse_states
    [['未処理','prepare'], ['処理中','progress'], ['完了','finish']]
  end

  def parse_state_label
    parse_states.rassoc(parse_state).try(:first)
  end

  def parse_state_prepare?
    parse_state == 'prepare'
  end

  def parse_state_progress?
    parse_state == 'progress'
  end

  def parse_state_finish?
    parse_state == 'finish'
  end

  def register_states
    [['未処理','prepare'], ['処理中','progress'], ['完了','finish']]
  end

  def register_state_label
    register_states.rassoc(register_state).try(:first)
  end

  def register_state_prepare?
    register_state == 'prepare'
  end

  def register_state_progress?
    register_state == 'progress'
  end

  def register_state_finish?
    register_state == 'finish'
  end

  def progressing?
    parse_state_progress? || register_state_progress?
  end

  def registerable?
    parse_state_finish? && register_state_prepare?
  end

  def upload_directory
    return nil unless site = content.site
    site_dir = "sites/#{format('%04d', site.id)}"
    md_dir  = self.class.to_s.underscore.pluralize
    id_dir  = format('%08d', id).gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    Rails.root.join("#{site_dir}/upload/#{md_dir}/#{id_dir}").to_s
  end

private

  def set_file_attributes
    if file.blank?
      return errors.add(:base, "ファイルを入力して下さい。")
    end

    self.filename = file.original_filename
    self.filedata = nil
    set_text_data if file_type == 'csv'
    set_gxml_data if file_type == 'gxml'
  end

  def upload_zipfile
    return if file.blank?
    return if file_type != 'shape' && file_type != 'csv_zip'
    return if upload_directory.blank?
    item = Sys::Storage::Entry.from_path(upload_directory, new_as: :directory)
    uploader = Sys::Storage::Uploader.new(item)
    @results, @unzip_results = uploader.upload_files([file],
                                                     overwrite: false,
                                                     unzip: true)
    return if file_type == 'shape'
    csvfile = Dir.glob("#{upload_directory}/**/*.csv").first
    return false if csvfile.blank?
    data = NKF::nkf('-w8 -Lw', ::File.read(csvfile))
    data = data.gsub(/\xE3\x80\x9C/, "\xEF\xBD\x9E")
    self.update_columns(parse_total: CSV.parse(data, :headers => true).size)
    self.update_columns(filedata: data)
  end

  def set_text_data
    begin
      data = NKF::nkf('-w8 -Lw', file.read)
      return errors.add(:base, "ファイルが空です。") if data.blank?
      data = data.gsub(/\xE3\x80\x9C/, "\xEF\xBD\x9E")
      self.parse_total = CSV.parse(data, :headers => true).size # format check
      self.filedata = data
    rescue => e
      return errors.add(:base, "ファイル形式が不正です。(#{e})")
    end
  end

  def set_gxml_data
    begin
      data = NKF::nkf('-w8 -Lw', file.read)
      return errors.add(:base, "ファイルが空です。") if data.blank?
      data = data.gsub(/\xE3\x80\x9C/, "\xEF\xBD\x9E")
      self.filedata = data
    rescue => e
      return errors.add(:base, "ファイル形式が不正です。(#{e})")
    end
  end

  def set_defaults
    self.import_type ||= self.class.name
    self.parse_state ||= 'progress'
    self.register_state ||= 'prepare'
  end
end
