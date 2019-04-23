class Gis::Categorization < ApplicationRecord
  include Sys::Model::Base

  belongs_to :categorizable, polymorphic: true
  belongs_to :category

end
