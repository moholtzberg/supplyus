class PaymentsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    authorize! :read, Payment
    @payments = Payment.order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @payments = @payments.lookup(params[:term]) if params[:term].present?
    end
    respond_to do |format|
      format.html
      format.json {render :json => @payments.map(&:number)}
    end
  end
  
  def new
    authorize! :create, Payment
    if params[:payment_type] == "check"
      @payment = Payment.new
    else
      @payment = CreditCardPayment.new
    end
    # puts "===================> #{params[:order_id]}"
    # @order = Order.find_by_id(params[:order_id])
    # puts @order.inspect
    # @account_id = @order.account_id
    # respond_to do |format|
    #   format.html {render :new}
    #   format.js { }
    # end
  end
  
  def create
    authorize! :create, Payment
    puts params
    if PaymentMethod.find(params[:payment][:payment_method]).name == "CreditCard"
      a = CreditCardPayment.new()
      a.first_name = params[:payment][:first_name]
      a.last_name = params[:payment][:last_name]
      a.credit_card_number = params[:payment][:credit_card_number]
      a.card_security_code = params[:payment][:card_security_code]
      a.expiration_month = params[:payment][:expiration_month]
      a.expiration_year = params[:payment][:expiration_year]
      a.amount = params[:payment][:amount]
      if a.authorize
        a.save
        complete
      else
        puts "-----XXX---> #{a.errors.messages}"
        render "payment"
      end
    elsif PaymentMethod.find(params[:payment][:payment_method]).name == "Check"
      c = Payment.new(params[:payment])
      c.payment_type = "CheckPayment"
      c.save
    end
  end
  
  # def create
  #   authorize! :create, Payment
  #   puts params[:payment][:account_id]
  #
  #   unless PaymentMethod.find(params[:payment][:payment_method]).name == "CreditCard"
  #     amount = params[:payment][:amount].to_i
  #     approved = true
  #   else
  #     a = Stripe::Charge.create(:amount => (params[:payment][:amount].to_i * 100), :currency => "usd", :customer => Account.find(params[:payment][:account_id]).stripe_customer_id)
  #     puts a.inspect
  #     if a.failure_code == nil
  #       amount = (a.amount/100).to_f
  #       approved = true
  #     end
  #   end
  #
  #   if approved == true
  #     p = Payment.new(:account_id => params[:payment][:account_id], :payment_method_id => params[:payment][:payment_method], :credit_card_id => params[:payment][:credit_card_id], :amount => amount)
  #     p.build_order_payment_application(:order_id => params[:payment][:order_id])
  #     p.save
  #   end
  #   redirect_to order_path(params[:payment][:order_id])
  # end
  
  # def show
  #   @payment = Payment.find(params[:id])
  # end
  
  # def capture
  #   p = CreditCardPayment.find(params[:id])
  #   if p.capture
  #     p.build_order_payment_application(:order_id => params[:payment][:order_id])
  #     p.save
  #   end
  #   redirect_to orders_path(params[:payment][:order_id])
  # end
  
  def sort_column
    puts Payment.column_names[0]
    Payment.column_names.include?(params[:sort]) ? params[:sort] : "authorization_code"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end