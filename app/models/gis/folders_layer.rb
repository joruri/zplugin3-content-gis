class Gis::FoldersLayer < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator

  belongs_to   :folder,  foreign_key: :folder_id,  class_name: 'Gis::Folder'
  belongs_to   :layer, foreign_key: :layer_id, class_name: 'Gis::Layer'

end
