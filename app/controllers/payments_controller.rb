class PaymentsController < ApplicationController
  layout "admin"
  
  def new
    @payment = Payment.new
    puts "===================> #{params[:invoice_id]}"
    @invoice = Invoice.find_by_id(params[:invoice_id])
    puts @invoice.inspect
    @account_id = @invoice.account_id
    # respond_to do |format|
    #   format.html {render :new}
    #   format.js { }
    # end
  end
  
  def create
    puts params[:account_id]
    a = Stripe::Charge.create(:amount => (params[:payment][:amount].to_i * 100), :currency => "usd", :customer => Account.find(params[:payment][:account_id]).stripe_customer_id)
    puts a.inspect
    if a.failure_code == nil
      p = Payment.create(:account_id => params[:payment][:account_id], :credit_card_id => params[:payment][:credit_card_id], :amount => (a.amount / 100).to_f)
      InvoicePaymentApplication.create(:invoice_id => params[:payment][:invoice_id], :payment_id => p.id)
    else
    end
  end
  
end