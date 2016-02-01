class ShopController < ApplicationController
  
  before_filter :find_categories
  before_filter :find_cart
  
  before_action :authenticate_user!, :only => :my_account
  
  def index
    @categories = Category.is_parent
    @items = Item.all
  end
  
  def category
    @category = Category.find_by(:slug => params[:category])
  end
  
  def item
    @category = Category.find_by(:slug => params[:category])
    @item = Item.find_by(:slug => params[:item])
  end
  
  def search
    @items = Item.where(nil)
    @items = @items.search(params[:keywords]) if params[:keywords].present?
  end
  
  def add_to_cart
    i = Item.find_by(:id => params[:cart][:item_id])
    c = Cart.find_or_create_by(:id => session[:cart_id])
    line = c.contents.by_item(i.id)
    unless line.blank?
      qty = line.first.quantity.to_f + params[:cart][:quantity].to_f
      line = line.first
      line.quantity = qty
      line.save
    else
      if current_user and !current_user.account.nil?
        c.contents.create(:item_id => params[:cart][:item_id], :quantity => params[:cart][:quantity], :price => i.actual_price(current_user.account.id))
      else
        c.contents.create(:item_id => params[:cart][:item_id], :quantity => params[:cart][:quantity], :price => i.price)
      end
      
    end
  end
  
  def update_cart
    lines = params[:lines]
    lines.each_with_index do |line, idx|
      id = line[1]["id"]
      qt = line[1]["quantity"]
      OrderLineItem.find(id).update_attributes(:quantity => qt)
    end
  end
  
  def cart
    @cart = Cart.find_by(:id => session[:cart_id])
  end
  
  def my_account
    
  end
  
  def edit_account
    @account = current_user.account
  end
  
  def find_categories
    @categories = Category.is_parent
  end
  
  def find_cart
    # if session[:cart_id].blank?
    #   if current_user
    #     session[:cart_id] = Cart.open.find_or_create_by(:account_id => current_user.account.id).id
    #   else
    #     session[:cart_id] = Cart.create.id
    #   end
    # end
    # puts "......---->> #{session[:cart_id]}"
    # @cart = Cart.find_by(:id => session[:cart_id]) unless @cart.nil? else @cart = Cart.create.id
    
    if !session[:cart_id].blank? and session[:cart_id].is_a? Numeric
      unless !Cart.find_by(:id => session[:cart_id]).nil?
        session[:cart_id] = Cart.create.id
      end
    else
      session[:cart_id] = Cart.create.id
    end
    @cart = Cart.find_by(:id => session[:cart_id])
  end
  
end