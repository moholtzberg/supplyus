class CheckoutController < ApplicationController
  layout "shop"
  
  before_filter :find_categories
  before_filter :find_cart
  
  before_action :authenticate_user!
  
  def check_authorization
    
  end
  
  def address
    @checkout = Checkout.find_by(:id => session[:cart_id])
    if current_user.account.nil?
      @address = Account.new
    else
      @address = current_user.account
    end
  end
  
  def update_address
    params[:checkout][:bill_to_account_name] = params[:checkout][:ship_to_account_name] unless !params[:checkout][:bill_to_account_name].blank?
    params[:checkout][:bill_to_address_1] = params[:checkout][:ship_to_address_1] unless !params[:checkout][:bill_to_address_1].blank?
    params[:checkout][:bill_to_address_2] = params[:checkout][:ship_to_address_2] unless !params[:checkout][:bill_to_address_2].blank?
    params[:checkout][:bill_to_city] = params[:checkout][:ship_to_city] unless !params[:checkout][:bill_to_city].blank?
    params[:checkout][:bill_to_state] = params[:checkout][:ship_to_state] unless !params[:checkout][:bill_to_state].blank?
    params[:checkout][:bill_to_zip] = params[:checkout][:ship_to_zip] unless !params[:checkout][:bill_to_zip].blank?
    params[:checkout][:bill_to_phone] = params[:checkout][:ship_to_phone] unless !params[:checkout][:bill_to_phone].blank?
    cart = Checkout.find_by(:id => session[:cart_id])
    if current_user.has_account
      cart.account_id = current_user.account.id
      cart.order_line_items.each {|c| c.price = c.item.actual_price(cart.account_id)}
    end
    cart.update_attributes(checkout_params)
    if cart.save
      redirect_to checkout_shipping_path
    end
  end
  
  def shipping
    @checkout = OrderShippingMethod.new(:order_id => session[:cart_id])
  end
  
  def update_shipping
    shipping = ShippingMethod.find_by(:id => params[:order_shipping_method][:shipping_method_id])
    puts "---> #{shipping.inspect}"
    unless OrderShippingMethod.find_by(:order_id => session[:cart_id]).nil?
      "WE HAVE AND ID"
      o = OrderShippingMethod.find_by(:order_id => session[:cart_id])
    else
      o = OrderShippingMethod.new(:order_id => session[:cart_id])
    end
    puts "-----> #{o.inspect}"
    o.update_attributes(:shipping_method_id => shipping.id, :amount => shipping.calculate(@cart.sub_total))
    
    # if o.save
      redirect_to checkout_payment_path
    # end
  end
  
  def payment
    @checkout = Checkout.find_by(:id => session[:cart_id])
    if current_user.has_account
      redirect_to checkout_confirm_path
    end
  end
  
  def confirm
    @checkout = Checkout.find_by(:id => session[:cart_id])
  end
  
  def complete
    c = Checkout.find_by(:id => session[:cart_id])
    c.completed_at = Time.now
    if c.save
      if c.complete
        session[:cart_id] = nil
        puts "GOING INTO THE MAILER"
        OrderMailer.order_confirmation(c.id).deliver_later
        redirect_to my_account_path
      end
      
    end
  end
  
  def find_categories
    @categories = Category.is_parent
  end
  
  def find_cart
    if !session[:cart_id].blank? and session[:cart_id].is_a? Numeric
      unless !Cart.find_by(:id => session[:cart_id]).nil?
        session[:cart_id] = Cart.create.id
      end
    else
      session[:cart_id] = Cart.create.id
    end
    @cart = Cart.find_by(:id => session[:cart_id])
  end
  
  def shipping_params
    params.require(:order_shipping_method).permit(:shipping_method_id)
  end
  
  def checkout_params
    params.require(:checkout).permit(
    :bill_to_account_name, :bill_to_attention, :bill_to_address_1, :bill_to_address_2, :bill_to_city, :bill_to_state, :bill_to_zip, :bill_to_phone, 
    :ship_to_account_name, :ship_to_attention, :ship_to_address_1, :ship_to_address_2, :ship_to_city, :ship_to_state, :ship_to_zip, :ship_to_phone, :po_number
    )
  end
  
end