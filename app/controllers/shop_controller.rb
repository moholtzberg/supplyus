class ShopController < ApplicationController
  
  before_filter :find_categories
  before_filter :find_cart
  
  before_action :authenticate_user!, :only => [:my_account, :my_items, :view_account, :view_order, :view_invoice, :pay_invoice, :edit_account]
  
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
    categories = []
    categories.push(@category.id)
    categories.push(@category.children.map(&:id))
    categories = categories.flatten.compact
    @items = Item.search(include: [:categories, :item_categories, :features, :brand, :images]) do
      fulltext params[:keywords] if params[:keywords].present?
      with(:category_ids, categories)
      stats :actual_price
      with(:actual_price, Range.new(*params[:price_range].split("..").map(&:to_i))) if params[:price_range].present?
      # with(:brand, params[:brand]) if params[:brand].present?
      if params[:specs].present?
        params[:specs].each do |param|
          with(:specs, param)
        end
      end
      # facet :brand
      facet :specs
      if params[:sort_by].present?
        order_by(*params[:sort_by])
      end
      order_by(:score, :desc)
      paginate(:page => params[:page])
    end
    if @items.results.any?
      max = @items.stats(:actual_price).max
      @items.build { facet :actual_price, :range => 0..max, :range_interval => (max/4).ceil }
      @items.execute
    end
  end
  
  def item
    @category = Category.where("slug = lower(?)", params[:category].downcase).take
    if Item.where("slug = lower(?)", params[:item].downcase).take.nil?
      raise ActionController::RoutingError.new('Not Found')
    end
    @item = Item.where("slug = lower(?)", params[:item].downcase).includes(:prices, :item_properties, :item_categories => [:category]).take
  end
  
  def search
    # @items = Item.where(nil).active
    @items = []
    @items = Item.search(include: [:prices, :categories, :item_categories, :features, :brand, :images, :item_lists]) do
      fulltext params[:keywords] if params[:keywords].present?
      stats :actual_price
      with(:actual_price, Range.new(*params[:price_range].split("..").map(&:to_i))) if params[:price_range].present?
      # with(:brand, params[:brand]) if params[:brand].present?
      if params[:specs].present?
        params[:specs].each do |param|
          with(:specs, param)
        end
      end
      # facet :brand
      facet :specs
      if params[:sort_by].present?
        order_by(*params[:sort_by])
      end
      order_by(:score, :desc)
      paginate(:page => params[:page])
    end
    if @items.results.any?
      max = @items.stats(:actual_price).max
      @items.build { facet :actual_price, :range => 0..max, :range_interval => (max/4).ceil }
      @items.execute
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
      line.price = line.item.actual_price(current_user.try(:account_id), line.quantity)
      line.save
    else
      
      if current_user and !current_user.account.nil?
        if current_user.has_account
          @cart.account_id = current_user.account.id
        end
        @cart.contents.create(:item_id => params[:cart][:item_id], :quantity => params[:cart][:quantity].to_i, :price => i.actual_price(current_user.account_id, params[:cart][:quantity].to_i))
      else
        @cart.contents.create(:item_id => params[:cart][:item_id], :quantity => params[:cart][:quantity].to_i, :price => i.actual_price(nil, params[:cart][:quantity].to_i))
      end
      
    end
  end
  
  def update_cart
    lines = params[:lines]
    lines.each_with_index do |line, idx|
      id = line[1]["id"]
      qt = line[1]["quantity"].to_i
      oli = OrderLineItem.find(id)
      oli.update_attributes(:quantity => qt, :price => oli.item.actual_price(current_user.try(:account_id), qt))
    end
  end
  
  def cart
    @cart = Cart.find_or_initialize_by(:id => cookies.permanent.signed[:cart_id])
    if current_user && current_user.has_account
      @cart.account_id = current_user.account.id
      @cart.order_line_items.each do |c| 
        c.price = c.item.actual_price(@cart.account_id, c.quantity)
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
    @account = Customer.find_by(:id => params[:account_id])
    if current_user.my_account_ids.include?(@account.id)
      @orders = @account.orders.is_complete.includes(:order_shipping_method).order(:completed_at).paginate(:page => params[:page], :per_page => 10)
    else
      redirect_to "/"
    end
  end
  
  def view_order
    @order = Order.find_by(:number => params[:order_number])
    @shipments = Shipment.where(:order_id => @order.id)
    if current_user.my_account_ids.include?(@order.account_id)
      respond_to do |format|
        format.html
        format.pdf do
          render :pdf => "#{@order.number}", :title => "#{@order.number}", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false, :template => 'shop/view_order.html.erb', :print_media_type => true
        end
      end
    else
      redirect_to "/"
    end
  end
  
  def view_invoice
    @invoice = Order.find_by(:number => params[:invoice_number])
    if current_user.my_account_ids.include?(@invoice.account_id)
      respond_to do |format|
        format.html
        format.pdf do
          render :pdf => "#{@invoice.number}", :title => "#{@invoice.number}", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false, :template => 'shop/view_invoice.html.erb', :print_media_type => true
        end
        format.xls
      end
    else
      redirect_to "/"
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