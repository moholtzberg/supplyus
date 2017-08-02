class PaymentsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    authorize! :read, Payment
    @payments = Payment.order(sort_column + " " + sort_direction).includes(:order_payment_applications => [:order])
    unless params[:term].blank?
      @payments = @payments.lookup(params[:term]) if params[:term].present?
    end
    @payments = @payments.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.json {render :json => @payments.map(&:number)}
    end
  end
  
  def new
    authorize! :create, Payment
    @payment = Payment.new
  end
  
  def create
    authorize! :create, Payment
    if PaymentMethod.find(params[:payment][:payment_method]).name == "CreditCardPayment"
      payment = CreditCardPayment.new(
        :first_name => params[:payment][:first_name],
        :last_name => params[:payment][:last_name],
        :credit_card_number => params[:payment][:credit_card_number],
        :card_security_code => params[:payment][:card_security_code],
        :expiration_month => params[:payment][:expiration_month],
        :expiration_year => params[:payment][:expiration_year],
        :amount => params[:payment][:amount]
      )
      
      if payment.authorize
        payment.save
        complete
      else
        puts "-----XXX---> #{a.errors.messages}"
        render "payment"
      end
    else
      payment = Payment.new(
        :amount => params[:payment][:amount],
        :account_name => params[:payment][:account_name],
        :payment_method => PaymentMethod.find_by(:name => params[:payment][:payment_method]),
        :check_number => params[:payment][:check_number],
        :date => params[:payment][:date],
      )
      payment.payment_type = "CheckPayment"
      payment.save
    end
    
    params[:order_payment_applications].each do |line|
      if line[1]["applied_amount"].to_d > 0
        payment.order_payment_applications.new(:order_id => line[1]["order_id"], :applied_amount => line[1]["applied_amount"].to_d.to_s)
      end
    end
    
    if payment.save
      @payments = Payment.order(sort_column + " desc").includes(:order_payment_applications => [:order])
      flash[:notice] = "Payment saved successfully!"
      @payments = @payments.paginate(:page => params[:page], :per_page => 25)
    end
  end

  def finalize
    @payment = Payment.find(params[:id])
    authorize! :update, Payment
    @payment.finalize
  end
  
  private
  
  def payment_params
    params.require(:payment).permit(:amount, :account_name, :payment_method_id, :check_number, :date)
  end
  
  def sort_column
    Payment.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end