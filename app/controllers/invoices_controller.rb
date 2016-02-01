class InvoicesController < ApplicationController
  layout "admin"
  
  def index
    @invoices = Invoice.all
    if params[:account_id]
      @invoices.by_account(params[:account_id])
    end
  end
  
  def show
    @invoice = Invoice.find(params[:id])
  end
  
  def new
    @unbilled_charges = Charge.by_account(params[:account_id]).unbilled
    @invoice = Invoice.new(account_id: params[:account_id])
    @unbilled_charges.count.times { @invoice.charges.build }
    @charge = Charge.new(account_id: params[:account_id])
  end
  
  def create
    ids = []
    charges = params[:invoice][:charges].each_pair {|k| ids.push(k[1].to_a.flatten[1]) }
    puts ids.inspect
    @charges = Charge.find(ids)
    @invoice = Invoice.create(:number => params[:invoice][:number], :account_id => params[:invoice][:account_id], :date => params[:invoice][:date])
    @charges.each {|c| c.update(:invoice_id => @invoice.id)}
    if @invoice.save
      redirect_to invoice_path(@invoice.id, :account_id => @invoice.account_id)
    else
      render :new
    end
  end
  
end