class Gis::Category < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept
  include Sys::Model::Tree
  include Zplugin3::Content::Webdb::Model::Rel::RelatedPage

  default_scope { order(parent_id: :asc, level_no: :asc, sort_no: :asc, name: :asc) }

  enum_ish :state, [:public, :closed], default: :public, predicate: true

  belongs_to :concept, foreign_key: :concept_id, class_name: 'Cms::Concept'
  belongs_to :content, class_name: 'Gis::Content::Entry', required: true

  belongs_to :parent, foreign_key: :parent_id, class_name: self.name, counter_cache: :children_count

  has_many :children, foreign_key: :parent_id, class_name: self.name, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: [:content_id, :parent_id] },
                   format: { with: /\A[0-9A-Za-z@\.\-_\+]+\z/ }
  validates :title, presence: true
  validates :state, presence: true

  has_many :categorizations, dependent: :destroy
  has_many :categorized_entries, through: :categorizations, source: :categorizable, source_type: 'Gis::Entry'
  has_many :public_children, -> { public_state },
                             foreign_key: :parent_id, class_name: self.name

  delegate :site, to: :content
  delegate :site_id, to: :content

  before_validation :set_attributes_from_parent

  scope :with_root, -> { where(parent_id: nil) }
  scope :public_state, -> { where(state: 'public') }

  scope :with_icon, ->{
    where(arel_table[:icon_uri].not_eq(nil))
  }


  def tree_title(prefix: '　　', depth: 0)
    prefix * [level_no - 1 + depth, 0].max + title
  end

  def descendants(categories=[])
    categories << self
    children.each {|c| c.descendants(categories) }
    return categories
  end

  def descendants_ids
    descendants_with_preload.map(&:id)
  end

  def descendants_with_preload
    GpCategory::CategoriesPreloader.new(self).preload(:descendants)
    descendants
  end

  def public_descendants(categories=[])
    return categories unless self.state_public?
    categories << self
    public_children.each {|c| c.public_descendants(categories) }
    return categories
  end

  def public_descendants_with_preload
    GpCategory::CategoriesPreloader.new(self).preload(:public_descendants)
    public_descendants
  end

  def descendants_for_option(categories=[])
    categories << [tree_title, id]
    children.includes(:children).each {|c| c.descendants_for_option(categories) } unless children.empty?
    return categories
  end

  def ancestors(categories=[])
    parent.ancestors(categories) if parent
    categories << self
  end

  def public_ancestors
    ancestors.select { |c| c.state == 'public' }
  end

  def path_from_root_category
    ancestors.map{|a| a.name }.join('/')
  end

private

  def set_attributes_from_parent
    if parent
      self.level_no = parent.level_no + 1
    else
      self.level_no = 1
    end
  end

end
