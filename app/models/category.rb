class Category < ActiveRecord::Base
  
  belongs_to :parent, :class_name => "Category"
  has_many :items
  has_many :children, :class_name => "Category", :foreign_key => :parent_id
  
  scope :active, -> () { where(:active => true) }
  scope :is_parent, -> () { where(:parent_id => nil) }
  # scope :children,  -> (parent_id) { where(:parent_id => parent_id) }
  
end
