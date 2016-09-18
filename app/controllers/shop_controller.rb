class ShopController < ApplicationController
  
  before_filter :find_categories
  before_filter :find_cart
  
  before_action :authenticate_user!, :only => :my_account
  
  def check_authorization
    
  end
  
  def index
    @categories = Category.is_parent.is_active
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
    @params = params
    @category = Category.where("slug = lower(?)", @params[:category].downcase).take
    if Category.where("slug = lower(?)", @params[:category].downcase).take.nil?
      raise ActionController::RoutingError.new('Not Found')
    end
    # @items = Item.where(:category_id => @category.id).paginate(:page => params[:page])
    # @items = ItemCategory.where(:category_id => [@category.id, @category.children.map(&:id)]).includes(:item => [:brand, :category, :images]).paginate(:page => params[:page])
    
    categories = []
    categories.push(@category.id)
    categories.push(@category.children.map(&:id))
    categories = categories.flatten.compact
    @items = Item.search do 
      
      with(:category_ids, categories)
      with(:category_ids, params[:category_ids]) if params[:category_ids].present?
      facet :category_ids
      
      brand = with(:brand, params[:brand]) if params[:brand].present?
      facet :brand
      
      # facet :price, :range => 0..1000, :range_interval => 100
      
      # with(:price, params[:min_price]).greater_than_or_equal_to(params[:min_price]) if params[:min_price].present?
      # with(:price, params[:max_price]).greater_than_or_equal_to(params[:max_price]) if params[:max_price].present? 
      # price_range = params[:price].split("..").map(&:to_i) if params[:price].present?
      # with(:price, Range.new(price_range[0], price_range[1])) if params[:price].present?
      # with(:item_properties, params[:item_properties]) if params[:item_properties].present?
      order_by(:score, :desc)
      paginate(:page => params[:page])
    end
  end
  
  def item
    @category = Category.where("slug = lower(?)", params[:category].downcase).take
    if Item.where("slug = lower(?)", params[:item].downcase).take.nil?
      raise ActionController::RoutingError.new('Not Found')
    end
    @item = Item.where("slug = lower(?)", params[:item].downcase).includes(:group_item_prices, :account_item_prices, :item_properties, :item_categories => [:category]).take
  end
  
  def search
    # @items = Item.where(nil).active
    @items = []
    @items = Item.search do
      fulltext params[:keywords] if params[:keywords].present?
      facet :price, :range => 0..1000, :range_interval => 100
      with(:brand, params[:brand]) if params[:brand].present?
      with(:color, params[:color]) if params[:color].present?
      with(:size, params[:size]) if params[:size].present?
      with(:format, params[:format]) if params[:format].present?
      with(:recycled, params[:recycled]) if params[:recycled].present?
      with(:material, params[:material]) if params[:material].present?
      with(:application, params[:application]) if params[:application].present?
      facet :brand, :color, :size, :format, :recycled, :material, :application
      facet :property_ids, :specification_ids
      category_ids = with(:category_ids, params[:category_ids]) if params[:category_ids].present?
      facet :category_ids, :exclude => [category_ids].compact
      # with(:scent, params[:scent]) if params[:scent].present?
      # with(:price, params[:min_price]).greater_than_or_equal_to(params[:min_price]) if params[:min_price].present?
      # with(:price, params[:max_price]).greater_than_or_equal_to(params[:max_price]) if params[:max_price].present?
      # price_range = params[:price].split("..").map(&:to_i) if params[:price].present?
      # with(:price, Range.new(price_range[0], price_range[1])) if params[:price].present?
      # with(:property_ids, params[:property_ids]) if params[:property_ids].present?
      # 
      # with(:specification_ids, params[:specification_ids]) if params[:specification_ids].present?
      order_by(:score, :desc)
      paginate(:page => params[:page])
    end
  end
  
  def search_autocomplete
   @occurences = Item.render_auto(params[:q])
   render json: @occurences
  end
  
  def add_to_cart
    i = Item.find_by(:id => params[:cart][:item_id])
    puts "SESSION --------> #{cookies.permanent.signed[:cart_id]}"
    if !cookies.permanent.signed[:cart_id].blank? and cookies.permanent.signed[:cart_id].is_a? Numeric
      @cart = Cart.find_by(:id => cookies.permanent.signed[:cart_id])
      unless @cart.completed_at.nil?
        @cart = Cart.create
        cookies.permanent.signed[:cart_id] = @cart.id
      end
    else
      @cart = Cart.create
      cookies.permanent.signed[:cart_id] = @cart.id
    end
    # c = Cart.find_or_create_by(:id => session[:cart_id])
    @cart.ip_address = request.remote_ip
    @cart.save
    line = @cart.contents.by_item(i.id)
    unless line.blank?
      qty = line.first.quantity.to_f + params[:cart][:quantity].to_f
      line = line.first
      line.quantity = qty
      line.save
    else
      
      if current_user and !current_user.account.nil?
        if current_user.has_account
          @cart.account_id = current_user.account.id
        end
        @cart.contents.create(:item_id => params[:cart][:item_id], :quantity => params[:cart][:quantity].to_i, :price => i.actual_price(current_user.account.id))
      else
        @cart.contents.create(:item_id => params[:cart][:item_id], :quantity => params[:cart][:quantity].to_i, :price => i.price)
      end
      
    end
  end
  
  def update_cart
    lines = params[:lines]
    lines.each_with_index do |line, idx|
      id = line[1]["id"]
      qt = line[1]["quantity"].to_i
      OrderLineItem.find(id).update_attributes(:quantity => qt)
    end
  end
  
  def cart
    @cart = Cart.find_or_initialize_by(:id => cookies.permanent.signed[:cart_id])
    if current_user && current_user.has_account
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
    # @items = OrderLineItem.joins(:order, :item).where("orders.account_id = ?", current_user.account.id).select(:item_id).uniq(:item_id).map {|a| a.item_id}
    # @items = Item.where(id: @items).joins(:order_line_items).group(:item_id).order("order_line_items.quantity DESC")
    
    if current_user.account
      order_ids = Order.where(:account_id => current_user.account.id).where.not(:completed_at => nil).map(&:id)
    end
    
    item_ids = OrderLineItem.where(:order_id => order_ids, :quantity => 1..Float::INFINITY).map {|q| q.item_id unless q.actual_quantity < 1}
    @items = Item.where(:id => item_ids).active.order(:name)
    @items = @items.paginate(:page => params[:page])
  end
  
  def view_account
    @account = Account.find_by(:id => params[:account_id])
    @orders = @account.orders.is_complete.includes(:order_shipping_method).order(:completed_at).paginate(:page => params[:page], :per_page => 10)
    # @invoices = @account.invoices.paginate(:page => params[:page], :per_page => 10)
  end
  
  def view_order
    @order = Order.find_by(:number => params[:order_number])
    @shipments = Shipment.where(:order_id => @order.id)
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "#{@order.number}", :title => "#{@order.number}", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false, :template => 'shop/view_order.html.erb', :print_media_type => true
      end
    end
  end
  
  def view_invoice
    @invoice = Order.find_by(:number => params[:invoice_number])
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "#{@invoice.number}", :title => "#{@invoice.number}", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false, :template => 'shop/view_invoice.html.erb', :print_media_type => true
      end
      format.xls
    end
  end
  
  def pay_invoice
    @account = current_user.account
    @credit_card = CreditCard.new
    @invoice = Invoice.find_by(:number => params[:invoice_number])
    @payment = Payment.new
  end
  
  def edit_account
    @account = current_user.account
  end
  
  def find_categories
    @store_name = StoreSetting.store_name
    @store_phone_number = StoreSetting.store_phone_number
    @store_address = StoreSetting.store_address
    @store_city = StoreSetting.store_city
    @store_state = StoreSetting.store_state
    @store_zip = StoreSetting.store_zip
    @menu = Category.is_parent.is_active.show_in_menu.includes(:children)
  end
  
  def find_cart
    
    if params[:debug_cart_id]
      cookies.permanent.signed[:cart_id] = params[:debug_cart_id].to_i
      if params[:debug_cart_id] == nil
        cookies.permanent.signed[:cart_id] = nil
      end
    end
    
    if cookies.permanent.signed[:cart_id] and cookies.permanent.signed[:cart_id].is_a? Numeric
      if Cart.find_by(:id => cookies.permanent.signed[:cart_id])
        @cart = Cart.find_or_initialize_by(:id => cookies.permanent.signed[:cart_id])
      else
        @cart = Cart.find_or_initialize_by(:id => nil)
      end
    else
      @cart = Cart.find_or_initialize_by(:id => nil)
    end
    cookies.permanent.signed[:cart_id] = @cart.id
    
    puts "CCAARRTT -> #{@cart.number}"
  end
  
end