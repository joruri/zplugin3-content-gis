class Gis::DrawingSetting < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  WIDTH_OPTIONS = [["0.5px", "0.5"], ["1.0px", "1.0"], ["1.5px", "1.5"],
    ["2.0px", "2.0"], ["2.5px", "2.5"], ["3.0px", "3.0"], ["3.5px", "3.5"],
    ["4.0px", "4.0"], ["4.5px", "4.5"], ["5.0px", "5.0"], ["5.5px", "5.5"],
    ["6.0px", "6.0"],["6.5px", "6.5"],["7.0px", "7.0"]]

  enum_ish :geometry_type, [:point, :line, :polygon], default: :point
  enum_ish :label_position, ['AUTO', 'ul', 'uc', 'ur', 'cl', 'cc', 'cr', 'll', 'lc', 'lr']
  enum_ish :label_size, [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]

  belongs_to :layer, foreign_key: :layer_id, class_name: 'Gis::Layer'

  def concept
    layer.concept
  end

  def label_column_options
    []
  end

  def line_width_text
    WIDTH_OPTIONS.each{|a| return a[0] if a[1] == line_width }
    return nil
  end



end
