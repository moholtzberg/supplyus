class Role < ActiveRecord::Base

  # First step!
  # Add role "super_admin" to your main admin - super_user has all permissions, this user can work with roles only after this step.
  # User.find(1).add_role :super_admin

  has_and_belongs_to_many :users, :join_table => :users_roles

  belongs_to :resource,
             :polymorphic => true
             # For rails >= 5
             # ,:optional => true

  has_many :permissions, dependent: :destroy

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true
  validates :name, presence: true
  validates :name, uniqueness: true

  scopify

  attr_accessor :mdl_name, :can_create, :can_read, :can_update, :can_destroy

  MODELS_LIST = [
          :user,
          :account,
          :role,
          :item,
          :vendor,
          :brand,
          :brand_import,
          :category,
          :group,
          :setting,
          :customer,
          :order,
          :order_line_item,
          :charge,
          :payment,
          :credit_card,
          :shipment,
          :invoice,
          :inventory,
          :item_import,
          :item_vendor_price,
          :item_vendor_price_import,
          :account_item_price,
          :account_item_price_import,
          :group_item_price, 
          :purchase_order,
          :purchase_order_line_item
  ]

end
