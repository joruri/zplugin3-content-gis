class Gis::Folder < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept

  belongs_to :portal_map, foreign_key: :map_id, class_name: 'Gis::Map'

  enum_ish :state, [:draft, :public, :closed], default: :public, predicate: true

  has_many :folder_layers, foreign_key: :folder_id,  class_name: 'Gis::FoldersLayer', dependent: :destroy
  accepts_nested_attributes_for :folder_layers, allow_destroy: true

  has_many :layers, through: :folder_layers

  nested_scope :in_site, through: :portal_map

  scope :public_state, -> { where(state: 'public') }

  def concept
    portal_map.concept
  end

  def build_default_layer(options = {})
    return if folder_layers.present?

    folder_layers.build(sort_no: 10)
  end

private

  def reject_folder_layer
    exists = attributes[:id].present?
    invalid = attributes[:layer_id].blank?
    attributes.merge!(_destroy: 1) if exists && invalid
    !exists && invalid
  end

end
