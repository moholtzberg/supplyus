class ItemVendorPricesController < ApplicationController
  layout "admin"
  respond_to :html, :json
  
  def index
    item_id = Item.find_by(:number => params[:item_number])
    @item_price = ItemVendorPrice.where(:item_id => item_id, :vendor_id => params[:vendor_id]).first
    
    puts "------------------> #{@item_price.inspect}"
    
    respond_to do |format|
      format.json { render json: @item_price }
    end
  end
  
  def new
    authorize! :create, ItemVendorPrice
    @item_vendor_price = ItemVendorPrice.new(:item_id => params[:item_id])
  end
  
  def create
    authorize! :create, ItemVendorPrice
    puts params.inspect
    item = Item.find_by(:number => params[:item_vendor_price][:item_number])
    acct = Vendor.find_by(:name => params[:item_vendor_price][:vendor_name])
    puts item.inspect
    puts acct.inspect
    item_price = ItemVendorPrice.where(:item_id => item.id, :vendor_id => acct.id).first
    puts item_price
    if item_price.nil?
      item_price = ItemVendorPrice.new(:item_id => item.id, :vendor_id => acct.id)
    end
    item_price.price = params[:item_vendor_price][:price]
    item_price.vendor_item_number = params[:item_vendor_price][:vendor_item_number] unless params[:item_vendor_price][:vendor_item_number].nil?
    item_price.save
    @item = item
  end
  
  def show
    
  end
  
end