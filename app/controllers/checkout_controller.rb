class CheckoutController < ApplicationController
  layout "shop"
  
  before_filter :find_categories
  before_filter :find_cart
  
  before_action :authenticate_user!
  
  def check_authorization
    
  end
  
  def address
    @checkout = Checkout.find_by(:id => cookies.permanent.signed[:cart_id])
    if current_user.account
      a = current_user.account
      @checkout.ship_to_account_name = a.name if @checkout.ship_to_account_name.nil?
      @checkout.ship_to_address_1 = a.address_1 if @checkout.ship_to_address_1.nil?
      @checkout.ship_to_address_2 = a.address_2 if @checkout.ship_to_address_2.nil?
      @checkout.ship_to_city      = a.city if @checkout.ship_to_city.nil?
      @checkout.ship_to_state     = a.state if @checkout.ship_to_state.nil?
      @checkout.ship_to_zip       = a.zip if @checkout.ship_to_zip.nil?
      @checkout.ship_to_phone     = a.phone if @checkout.ship_to_phone.nil?
      @checkout.bill_to_email     = a.bill_to_email if @checkout.bill_to_email.nil?
    end
    @checkout.ship_to_attention = "#{current_user.first_name} #{current_user.last_name}" if @checkout.ship_to_attention.nil?
    @checkout.email             = current_user.email if @checkout.email.nil?
    @checkout.user_id           = current_user.id if @checkout.user_id.nil?
  end
  
  def update_address
    params[:checkout][:bill_to_account_name] = params[:checkout][:ship_to_account_name] unless !params[:checkout][:bill_to_account_name].blank?
    params[:checkout][:bill_to_address_1] = params[:checkout][:ship_to_address_1] unless !params[:checkout][:bill_to_address_1].blank?
    params[:checkout][:bill_to_address_2] = params[:checkout][:ship_to_address_2] unless !params[:checkout][:bill_to_address_2].blank?
    params[:checkout][:bill_to_city] = params[:checkout][:ship_to_city] unless !params[:checkout][:bill_to_city].blank?
    params[:checkout][:bill_to_state] = params[:checkout][:ship_to_state] unless !params[:checkout][:bill_to_state].blank?
    params[:checkout][:bill_to_zip] = params[:checkout][:ship_to_zip] unless !params[:checkout][:bill_to_zip].blank?
    params[:checkout][:bill_to_phone] = params[:checkout][:ship_to_phone] unless !params[:checkout][:bill_to_phone].blank?
    params[:checkout][:bill_to_email] = params[:checkout][:email] unless !params[:checkout][:bill_to_email].blank?

    cart = Checkout.find_by(:id => cookies.permanent.signed[:cart_id])
    if !params[:checkout][:account_id].blank?
      cart.account_id = params[:checkout][:account_id]
    end
    if cart.account_id.nil?
      if current_user.has_account
        cart.account_id = current_user.account.id
      end
    end
    cart.order_line_items.each {|c| c.price = c.item.actual_price(cart.account_id, c.quantity)}

    cart.update_attributes(checkout_params)

    unless OrderTaxRate.find_by(:order_id => cookies.permanent.signed[:cart_id]).nil?
      o = OrderTaxRate.find_by(:order_id => cookies.permanent.signed[:cart_id])
    else
      o = OrderTaxRate.new(:order_id => cookies.permanent.signed[:cart_id])
    end
    
    tax_rate = TaxRate.find_by(:zip_code => cart.ship_to_zip)
    o.update_attributes(:tax_rate => tax_rate)
    o.update_attributes(:amount => o.calculate)
    
    if cart.save
      redirect_to checkout_shipping_path
    else
      @checkout = cart
      if current_user.account.nil?
        @address = Account.new
      else
        @address = current_user.account
      end
      render "address"
    end
  end
  
  def shipping
    @checkout = OrderShippingMethod.new(:order_id => cookies.permanent.signed[:cart_id])
  end
  
  def update_shipping
    shipping = ShippingMethod.find_by(:id => params[:order_shipping_method][:shipping_method_id])
    unless OrderShippingMethod.find_by(:order_id => cookies.permanent.signed[:cart_id]).nil?
      o = OrderShippingMethod.find_by(:order_id => cookies.permanent.signed[:cart_id])
    else
      o = OrderShippingMethod.new(:order_id => cookies.permanent.signed[:cart_id])
    end
    o.update_attributes(:shipping_method_id => shipping.id, :amount => shipping.calculate(@cart.sub_total))
    # redirect_to checkout_confirm_path
    redirect_to checkout_payment_path
  end
  
  def payment
    @checkout = Checkout.find_by(:id => cookies.permanent.signed[:cart_id])
    @payment = Payment.new
    @order = @checkout
    @cards = current_user.account.main_service.credit_cards
    # if current_user.has_account
    #   redirect_to checkout_confirm_path
    # end
  end
  
  def update_payment
    puts params[:payment_method]
    @checkout = Checkout.find_by(:id => cookies.permanent.signed[:cart_id])
    @payment = Order.find_by(:id => cookies.permanent.signed[:cart_id]).payments.new
    @payment.account = current_user.account
    @payment.amount = Order.find_by(:id => cookies.permanent.signed[:cart_id]).total
    @payment.payment_method = PaymentMethod.find_or_create_by(name: params[:payment_method], active: true)
    if params[:payment_method] == 'credit_card'
      @payment.payment_type =  'CreditCardPayment'
      @payment = @payment.becomes CreditCardPayment
    else
      @payment.payment_type =  'CheckPayment'
      @payment = @payment.becomes CheckPayment
    end
    if !params[:credit_card_token].blank?
      @card = CreditCard.find_by(account_payment_service_id: @checkout.account.main_service.id, service_card_id: params[:credit_card_token])
    else
      @card = CreditCard.create({
        cardholder_name: params[:cardholder_name],
        credit_card_number: params[:credit_card_number],
        card_security_code: params[:card_security_code],
        expiration_month: params[:expiration_month],
        expiration_year: params[:expiration_year],
        account_payment_service_id: @checkout.account.main_service.id
      })
    end
    @payment.credit_card_id = @card&.id
    @cards = current_user.account.main_service.credit_cards
    if @card and @card.errors.empty? and @payment.authorize
      @payment.save
      OrderPaymentApplication.create(:order_id => @checkout.id, :payment_id => @payment.id, :applied_amount => @payment.amount)
      submit
    else
      render "payment"
    end
  end

  def apply_code
    discount_code = DiscountCode.find_by(code: params[:discount_code][:code])
    @order_discount_code = OrderDiscountCode.create(discount_code_id: discount_code.id, order_id: @cart.id) if discount_code
    @cart.reload
  end

  def remove_code
    @cart.order_discount_code.destroy
    @cart.reload
  end

  def confirm
    @checkout = Checkout.find_by(:id => cookies.permanent.signed[:cart_id])
  end
  
  def submit
    c = Checkout.find_by(:id => cookies.permanent.signed[:cart_id])
    c.email             = current_user.email if c.email.nil?
    c.user_id           = current_user.id if c.user_id.nil?
    if c.account.present? and c.account.credit_hold == false
      c.credit_hold = false
    else
      c.credit_hold = true
    end
    if c.save
      c.submit
      @cart.reload
      cookies.permanent.signed[:cart_id] = nil
      puts "GOING INTO THE MAILER"
      redirect_to my_account_order_path(@cart.number)
      # OrderMailer.order_confirmation(c.id, :bcc => "sales@247officesupply.com").deliver_later
    end
  end
  
  def find_categories
     @menu = Category.is_parent.is_active.show_in_menu
  end
  
  def find_cart
    if !cookies.permanent.signed[:cart_id].blank? and cookies.permanent.signed[:cart_id].is_a? Numeric
      unless !Cart.find_by(:id => cookies.permanent.signed[:cart_id]).nil?
        cookies.permanent.signed[:cart_id] = Cart.create.id
      end
    else
      cookies.permanent.signed[:cart_id] = Cart.create.id
    end
    @cart = Cart.find_by(:id => cookies.permanent.signed[:cart_id])
  end
  
  def shipping_params
    params.require(:order_shipping_method).permit(:shipping_method_id)
  end
  
  def checkout_params
    params.require(:checkout).permit(:credit_hold,
    :bill_to_account_name, :bill_to_attention, :bill_to_address_1, :bill_to_address_2, :bill_to_city, :bill_to_state, :bill_to_zip, :bill_to_phone, :bill_to_email,
    :ship_to_account_name, :ship_to_attention, :ship_to_address_1, :ship_to_address_2, :ship_to_city, :ship_to_state, :ship_to_zip, :ship_to_phone, :po_number, :email, :notes
    )
  end
  
end