module Gis::Model::Rel::Category
  extend ActiveSupport::Concern

  included do
    after_save :save_categories, if: -> { defined? @in_category_ids }
    has_many :categorizations, class_name: 'Gis::Categorization', as: :categorizable, dependent: :destroy
    has_many :categories, -> { where(Gis::Categorization.arel_table[:categorized_as].eq('Gis::Category')) },
             class_name: 'Gis::Category', through: :categorizations,
             after_add: proc {|d, c|
               d.categorizations.where(category_id: c.id, categorized_as: nil).first
                .update_columns(categorized_as: 'Gis::Category')
             }

    scope :categorized_into, ->(categories, categorizable_type: nil, categorized_as: 'Gis::Category', alls: false) {
      categorizable_type ||= self.to_s

      cats = Gis::Categorization.select(:categorizable_id)
                                       .where(categorizable_type: categorizable_type, categorized_as: categorized_as)
      if alls
        Array(categories).inject(all) { |rel, c| rel.where(id: cats.where(category_id: c)) }
      else
        where(id: cats.where(category_id: categories))
      end
    }

  end

  def in_category_ids=(val)
    @in_category_ids = val
  end

  def in_category_ids
    @in_category_ids ||= make_category_params(categories)
  end

  def in_categories
    @in_category_ids.blank? ? [] : content.categories.where(id: in_category_ids)
  end

  private

  def make_category_params(categories)
    categories.present? ? categories.map{|c| c.id } : []
  end

  def save_categories
    category_ids = in_category_ids.flatten.select(&:present?).map(&:to_i).uniq
    self.category_ids = category_ids
  end
end
