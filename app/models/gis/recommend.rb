class Gis::Recommend < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content
  include Gis::Model::Rel::Category
  include Gis::Model::Rel::DbCondition

  after_initialize :set_defaults

  enum_ish :state, [:public, :closed], default: :public, predicate: true
  enum_ish :operator_type, [:and, :or], default: :and

  after_save     Gis::Publisher::DbCallbacks.new, if: :changed?
  before_destroy Gis::Publisher::DbCallbacks.new

  belongs_to :content, class_name: 'Gis::Content::Entry', required: true
  belongs_to :db, class_name: 'Webdb::Db'
  scope :public_state, -> { where(state: 'public') }

  validates :name, presence: true
  validates :title, presence: true
  validates :sort_no, presence: true

  def url_for_search
    return nil unless node = content.public_node
    uri = node.public_uri
    uri += "?recommend[1][]=#{id}&target=#{db_id}"
    return uri
  end

  def criteria
    return {} if item_values.blank?
    search_criteria = item_values.dup
    item_values.each do | key, val |
      next if val.blank?
      search_criteria[key.to_sym] = val
      search_criteria[key.to_sym] = val['check'] if val.dig('check').present?
    end
    search_criteria[:category_ids] = categories.map{|c| c.id }if categories.present?
    search_criteria
  end

private

  def set_defaults
    self.item_values ||= {} if self.has_attribute?(:item_values)
  end

end
