class Category < ActiveRecord::Base
  
  belongs_to :parent, :class_name => "Category"
  has_many :item_categories
  has_many :items, :through => :item_categories
  has_many :children, :class_name => "Category", :foreign_key => :parent_id
  
  scope :is_active, -> () { where(:active => true) }
  scope :is_parent, -> () { where(:parent_id => nil) }
  scope :show_in_menu, -> () { where(:show_in_menu => true) }
  # scope :children,  -> (parent_id) { where(:parent_id => parent_id) }
  
  def self.lookup(term)
    where("lower(name) like (?) or lower(slug) like (?)", "%#{term.downcase}%", "%#{term.downcase}%")
  end
  
  def parent_name
    parent.try(:name)
  end
  
  def parent_name=(name)
    self.parent = Category.find_by(:name => name) if name.present?
  end
  
  def self.tokens(query)
    categories = where("lower(name) like ?", "%#{query}%")
    if categories.empty?
      [{id: "<<<#{query}>>>", name: "New: \"#{query}\""}]
    else
      categories
    end
  end

  def self.ids_from_tokens(tokens)
    tokens.gsub!(/<<<(.+?)>>>/) { create!(name: $1).id }
    tokens.split(',')
  end
  
end
