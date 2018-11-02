class PurchaseOrdersController < ApplicationController
  layout 'admin'
  before_action :set_purchase_order, only: [:show, :edit, :update, :destroy, :lock]
  load_and_authorize_resource except: [:datatables, :line_items_from_order, :lock]

  def datatables
    authorize! :read, PurchaseOrder
    render json: PurchaseOrderDatatable.new(view_context)
  end
  
  def show
    @purchase_order_line_items = @purchase_order.purchase_order_line_items.includes(:item)
    @receipts = PurchaseOrderReceipt.where(:purchase_order_id => @purchase_order.id)
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "#{@purchase_order.number}", :title => "#{@purchase_order.number}", :layout => 'admin_print.html.erb', :page_size => 'Letter', :background => false, :template => 'orders/show.html.erb', :print_media_type => true, :show_as_html => params[:debug].present?
      end
    end
  end

  def new
    if params[:vendor_id]
      @vendors = Vendor.find_by(:id => params[:vendor_id])
      @purchase_order = PurchaseOrder.new(:vendor_id => params[:vendor_id])
    else
      @vendors = Vendor.all
      @purchase_order = PurchaseOrder.new()
    end
  end
  
  def line_items_from_order
    authorize! :create, PurchaseOrder
    @order_line_items = OrderLineItem.where(order_id: params[:order_id])
    @purchase_order_line_items = []
    @order_line_items.each_with_index do |a,i|
      qty_for = PurchaseOrderLineItem.where(:order_line_item_id => a.id).map(&:quantity).sum
      if qty_for < a.actual_quantity
        poli = PurchaseOrderLineItem.new(item_id: a.item_id, price: a.item.cost_price, quantity: a.actual_quantity - (a.quantity_shipped + qty_for), order_line_item_id: a.id, purchase_order_line_number: i+1)
        @purchase_order_line_items << poli.to_po_form_hash
      end
    end
    respond_to do |format|
      format.json { render json: {purchase_order_notes: Order.find(params[:order_id]).number, purchase_order_line_items: @purchase_order_line_items}}
    end
  end
  
  def edit
    @vendors = Vendor.all
  end

  def create
    @purchase_order = PurchaseOrder.new(purchase_order_params)
    @vendors = Vendor.all
    respond_to do |format|
      if @purchase_order.save
        format.html { redirect_to @purchase_order, notice: 'Purchase order was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_order }
      else
        format.html { render :new }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @vendors = Vendor.all
    respond_to do |format|
      if @purchase_order.update(purchase_order_params)
        format.html { redirect_to @purchase_order, notice: 'Purchase order was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_order }
      else
        format.html { render :edit }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @purchase_order.destroy
    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def lock
    authorize! :update, PurchaseOrder
    @purchase_order.locked = true
    @purchase_order.save
    respond_to do |format|
      format.html { redirect_to @purchase_order, notice: 'Purchase order was successfully locked.' }
      format.json { render :show, status: :ok, location: @purchase_order }
    end
  end
  
  private

  def purchase_order_params
    params.require(:purchase_order).permit(:vendor_id, :number, :email, :po_number, :completed_at, :notes, :ship_from_vendor_name, :ship_from_attention, 
      :ship_from_address_1, :ship_from_address_2, :ship_from_city, :ship_from_state, :ship_from_zip, :ship_to_account_name, :ship_to_attention, 
      :ship_to_address_1, :ship_to_address_2, :ship_to_city, :ship_to_state, :ship_to_zip, :ship_to_phone, :shipping_method, :shipping_amount, 
      purchase_order_line_items_attributes: [:id, :_destroy, :item_id, :quantity, :quantity_received, :order_line_item_id, :price, :purchase_order_line_number])
  end
  
  def set_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end
  
end
