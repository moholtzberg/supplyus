class Permission < ActiveRecord::Base

  belongs_to :role
  validates :mdl_name, presence: true

end
