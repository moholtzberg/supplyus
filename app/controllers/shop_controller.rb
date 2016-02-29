class ShopController < ApplicationController
  
  before_filter :find_categories
  before_filter :find_cart
  
  before_action :authenticate_user!, :only => :my_account
  
  def check_authorization
    
  end
  
  def index
    @categories = Category.is_parent
    @items = Item.all
  end
  
  def categories
    parent = params[:parent_id].to_i
    @categories = Category.where(:parent_id => parent, :active => true)
    respond_to do |format|
      format.json {render :json => @categories}
    end
  end
  
  def category
    @category = Category.where("slug = lower(?)", params[:category].downcase).take
    if Category.where("slug = lower(?)", params[:category].downcase).take.nil?
      raise ActionController::RoutingError.new('Not Found')
    end
    # @items = Item.where(:category_id => @category.id).paginate(:page => params[:page])
    @items = ItemCategory.where(:category_id => [@category.id, @category.children.map(&:id)]).includes(:item => [:brand, :category, :images]).paginate(:page => params[:page])
  end
  
  def item
    @category = Category.where("slug = lower(?)", params[:category].downcase).take
    if Item.where("slug = lower(?)", params[:item].downcase).take.nil?
      raise ActionController::RoutingError.new('Not Found')
    end
    @item = Item.where("slug = lower(?)", params[:item].downcase).take
  end
  
  def search
    @items = Item.where(nil)
    @items = @items.search(params[:keywords]) if params[:keywords].present?
    @items = @items.paginate(:page => params[:page])
  end
  
  def add_to_cart
    i = Item.find_by(:id => params[:cart][:item_id])
    c = Cart.find_or_create_by(:id => session[:cart_id])
    c.ip_address = request.remote_ip
    c.save
    line = c.contents.by_item(i.id)
    unless line.blank?
      qty = line.first.quantity.to_f + params[:cart][:quantity].to_f
      line = line.first
      line.quantity = qty
      line.save
    else
      if current_user and !current_user.account.nil?
        if current_user.has_account
          c.account_id = current_user.account.id
        end
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
    if current_user && current_user.has_account
      puts "PUT?z"
      @cart.account_id = current_user.account.id
      @cart.order_line_items.each do |c| 
        c.price = c.item.actual_price(@cart.account_id)
        c.save!
      end
    end
  end
  
  def my_account
  end
  
  def my_items
    @items = OrderLineItem.joins(:order, :item).where("orders.account_id = ?", current_user.account.id).select(:item_id).uniq(:item_id).map {|a| a.item_id}
    @items = Item.where(id: @items).joins(:order_line_items).group(:item_id).order("order_line_items.quantity DESC")
  end
  
  def view_account
    @account = Account.find_by(:id => params[:account_id])
    @orders = @account.orders.open.is_complete.includes(:order_shipping_method).paginate(:page => params[:page], :per_page => 10)
  end
  
  def view_order
    @order = Order.find_by(:number => params[:order_number])
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