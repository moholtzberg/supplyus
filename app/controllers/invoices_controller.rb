class InvoicesController < ApplicationController
  layout "admin"
  
  def index
    authorize! :read, Invoice
    @invoices = Invoice.all
    if params[:account_id]
      @invoices.by_account(params[:account_id])
    end
    if params[:order_id]
      @invoices.by_order(params[:order_id])
    end
  end
  
  def show
    authorize! :read, Invoice
    @invoice = Invoice.find(params[:id])
  end
  
  def new
    authorize! :create, Invoice
    @order = Order.find_by(:id => params[:order_id])
    puts @order.submitted_at
    @invoice = Invoice.new(:order_id => @order.id)
    @line_items = OrderLineItem.where(:order_id => @order.id)
  end
  
  def create
    authorize! :create, Invoice
    invoice = Invoice.new(:date => params[:invoice][:date], :order_id => params[:order_id], :due_date => params[:invoice][:due_date])
    order = Order.find_by(:id => params[:order_id])
    order.update_attributes(:date => params[:invoice][:date], :due_date => params[:invoice][:due_date])
    params[:lines].each do |line|
      invoice.line_item_fulfillments.new(:order_line_item_id => line[1]["order_line_item_id"], :quantity_fulfilled => line[1]["quantity_fulfill_now"])
    end
    
    if invoice.save
      OrderMailer.invoice_notification(order.id).deliver_later
      redirect_to order_path(order.id)
    end
  end
  
  
  # def new
  #   @unbilled_charges = Charge.by_account(params[:account_id]).unbilled
  #   @invoice = Invoice.new(account_id: params[:account_id])
  #   @unbilled_charges.count.times { @invoice.charges.build }
  #   @charge = Charge.new(account_id: params[:account_id])
  # end
  # 
  # def create
  #   ids = []
  #   charges = params[:invoice][:charges].each_pair {|k| ids.push(k[1].to_a.flatten[1]) }
  #   puts ids.inspect
  #   @charges = Charge.find(ids)
  #   @invoice = Invoice.create(:number => params[:invoice][:number], :account_id => params[:invoice][:account_id], :date => params[:invoice][:date])
  #   @charges.each {|c| c.update(:invoice_id => @invoice.id)}
  #   if @invoice.save
  #     redirect_to invoice_path(@invoice.id, :account_id => @invoice.account_id)
  #   else
  #     render :new
  #   end
  # end
  
end