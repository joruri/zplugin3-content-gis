class Gis::Attachment < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Base::File::Db

  belongs_to :site, class_name: 'Cms::Site'

  belongs_to :registration

  nested_scope :in_site, through: :registration

end
