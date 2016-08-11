class PurchaseOrdersController < ApplicationController
  layout "admin"
    
  def index
    authorize! :read, PurchaseOrder
    @purchase_orders = PurchaseOrder.all
    unless params[:term].blank?
      @purchase_orders = @purchase_orders.lookup(params[:term]) if params[:term].present?
    end
    @purchase_orders = @purchase_orders.paginate(:page => params[:page], :per_page => 25)
  end
  
  def show
    @purchase_order = PurchaseOrder.find(params[:id])
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
    authorize! :create, PurchaseOrder
    if params[:vendor_id]
      @vendors = Vendor.find_by(:id => params[:vendor_id])
      @purchase_order = PurchaseOrder.create(:vendor_id => params[:vendor_id])
    else
      @vendors = Vendor.all
      @purchase_order = PurchaseOrder.create()
    end
    # @items = Inventory.out_of_stock.map(&:item)
    #
    # @items.each_with_index do |item|
    #   @purchase_order.purchase_order_line_items.create(:item_number => item.number, :price => item.cost_price, :quantity => item.inventory.qty_on_hand.abs)
    # end
    @order_line_item = PurchaseOrderLineItem.new
  end
  
  def edit
    @vendors = Vendor.all
    @purchase_order = PurchaseOrder.find(params[:id])
    @order_line_item = PurchaseOrderLineItem.new
  end

  def create
    @purchase_order = PurchaseOrder.new(purchase_order_params)

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
    authorize! :update, PurchaseOrder
    @purchase_order = PurchaseOrder.find(params[:id])
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
    @purchase_order = PurchaseOrder.find(params[:id])
    @purchase_order.destroy
    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def lock
    authorize! :update, PurchaseOrder
    @order_id = params[:id]
    @order = PurchaseOrder.find_by(:id => @order_id)
    @order.locked = true
    @order.save
  end
  
  private

  def purchase_order_params
    params.require(:purchase_order).permit(:vendor_id, :number, :email, :po_number, :completed_at, :notes, :ship_from_attention, :ship_from_address_1, :ship_from_address_2, :ship_from_city, :ship_from_state, :ship_from_zip, :ship_to_attention, :ship_to_address_1, :ship_to_address_2, :ship_to_city, :ship_to_state, :ship_to_zip, :ship_to_phone, :shipping_method, :shipping_amount)
  end
  
end
