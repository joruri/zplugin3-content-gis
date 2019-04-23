module Gis::Model::Rel::DbCondition
  extend ActiveSupport::Concern

  def item_criteria
    return {} if item_values.blank?
    item_conditions = {}
    item_values.each do |key, value|
      if value.is_a?(Hash) && value['check'].present?
         item_conditions[key] = value['check']
      else
        item_conditions[key] = value
      end
    end
    item_conditions
  end

end
