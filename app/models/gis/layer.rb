class Gis::Layer < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content
  include Gis::Model::Rel::Category
  include Sys::Model::Rel::EditableGroup
  include Sys::Model::Rel::File
  include Sys::Model::Auth::EditableGroup
  include Gis::Model::Rel::DbCondition
  #include Webdb::Model::Rel::Db

  SRID_OPTIONS =  [["緯度・経度／世界測地系",4326], ["緯度・経度／日本測地系",4301], ["平面直角座標第1系",2443],
                    ["平面直角座標第2系",2444], ["平面直角座標第3系",2445], ["平面直角座標第4系",2446], ["平面直角座標第5系",2447],
                    ["平面直角座標第6系",2448], ["平面直角座標第7系",2449], ["平面直角座標第8系",2450], ["平面直角座標第9系",2452],
                    ["平面直角座標第10系",2453], ["平面直角座標第11系",2454], ["平面直角座標第12系",2455], ["平面直角座標第13系",2456],
                    ["平面直角座標第14系",2457], ["平面直角座標第15系",2458], ["平面直角座標第16系",2459], ["平面直角座標第17系",2460],
                    ["平面直角座標第18系",2461]
                  ]

  OPACITY_OPTIONS = [["100%", 1.0],["90%",0.9],["80%", 0.8],["70%",0.7],["60%",0.6],
                      ["50%", 0.5],["40%",0.4],["30%", 0.3],["20%",0.2],["10%",0.1],["0%",0.0]
                    ]


  after_initialize :set_defaults

  enum_ish :state, [:group, :internal, :public, :closed], default: :internal, predicate: true
  enum_ish :geometry_type, [:point, :line, :polygon], default: :point, predicate: true
  enum_ish :kind, [:point, :wms, :raster, :kml, :gpx], default: :point, predicate: true

  belongs_to :content, class_name: 'Gis::Content::Entry', required: true
  belongs_to :db, class_name: 'Webdb::Db'

  has_many :draw_settings, foreign_key: :layer_id,  class_name: 'Gis::DrawingSetting', dependent: :destroy

  scope :public_state, -> { where(state: 'public') }

  def concept
    content.concept
  end

  def opacity_text
    OPACITY_OPTIONS.each{|a| return a[0] if a[1] == opacity }
    return nil
  end

  def srid_text
    SRID_OPTIONS.each{|a| return a[0] if a[1] == srid }
    return nil
  end

  def file_content_uri
    if content.public_portal_node.present?
      %Q(#{content.public_portal_node.public_uri}layer/#{name}/file_contents/)
    else
      %Q(#{content.admin_uri}/layers/#{id}/file_contents/)
    end
  end

  def public_json_uri
    return nil unless content.public_portal_node.present?
    %Q(#{content.public_portal_node.public_uri}layer/#{name}.json)
  end

private

  def set_defaults
    self.state ||= 'internal'
    self.geometry_type ||= 'point'
    self.item_values ||= {} if self.has_attribute?(:item_values)
  end


end
