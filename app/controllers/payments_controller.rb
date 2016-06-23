class PaymentsController < ApplicationController
  layout "admin"
  
  def new
    authorize! :create, Payment
    @payment = Payment.new
    puts "===================> #{params[:order_id]}"
    @order = Order.find_by_id(params[:order_id])
    puts @order.inspect
    @account_id = @order.account_id
    # respond_to do |format|
    #   format.html {render :new}
    #   format.js { }
    # end
  end
  
  def create
    authorize! :create, Payment
    puts params[:payment][:account_id]
    
    unless PaymentMethod.find(params[:payment][:payment_method]).name == "CreditCard"
      amount = params[:payment][:amount].to_i
      approved = true
    else
      a = Stripe::Charge.create(:amount => (params[:payment][:amount].to_i * 100), :currency => "usd", :customer => Account.find(params[:payment][:account_id]).stripe_customer_id)
      puts a.inspect
      if a.failure_code == nil
        amount = (a.amount/100).to_f
        approved = true
      end
    end
    
    if approved == true
      p = Payment.new(:account_id => params[:payment][:account_id], :payment_method_id => params[:payment][:payment_method], :credit_card_id => params[:payment][:credit_card_id], :amount => amount)
      p.build_order_payment_application(:order_id => params[:payment][:order_id])
      p.save
    end
    redirect_to order_path(params[:payment][:order_id])
  end
  
end