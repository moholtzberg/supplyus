class WarehousesController < ApplicationController
  layout "admin"
  respond_to :html, :json
  def index
    authorize! :read, Warehouse
    @warehouses = Warehouse.all
    unless params[:term].blank?
      @warehouses = @warehouses.lookup(params[:term]) if params[:term].present?
    end
    @warehouses = @warehouses.paginate(:page => params[:page], :per_page => 25)
    
  end
  
  def new
    authorize! :create, Warehouse
    @warehouse = Warehouse.new
    # @brands = Brand.active
    # @categories = Category.all
  end
  
  def show
    authorize! :read, Warehouse
    @warehouse = Warehouse.find_by(:id => params[:id])
    @inventories = Inventory.where(bin_id: @warehouse.bins).with_items.joins(:item).joins(:bin).order(:item_id)
    unless params[:term].blank?
      @inventories = @inventories.lookup(params[:term]) if params[:term].present?
    end
    @inventories = @inventories.paginate(:page => params[:page], :per_page => 25)
  end
  
  def search
    authorize! :read, Warehouse
    @results = Warehouse.where(nil)
    search_term = params[:keywords] if params[:keywords].present?
    search_term = params[:term] if params[:term].present?
    @results = @results.lookup(search_term).paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.json {render :json => @results.to_json}
    end
  end
  
  def create
    authorize! :create, Warehouse
    @warehouse = Warehouse.create(warehouse_params)
    @warehouses = Warehouse.all
    @warehouses = @warehouses.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def edit
    authorize! :update, Warehouse
    @warehouse = Warehouse.find_by(:id => params[:id])
  end
  
  def update
    authorize! :update, Warehouse
    @warehouse = Warehouse.find_by(:id => params[:id])
    if @warehouse.update_attributes(warehouse_params)
      flash[:notice] = "\"#{@warehouse.name}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    @warehouses = Warehouse.all
    @warehouses = @warehouses.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.js
      format.json do 
        respond_with_bip(@warehouse)
      end
    end
  end
  
  def destroy
    authorize! :destroy, Warehouse
    e = Warehouse.find_by(:id => params[:id])
    e.destroy!
    @warehouses = Warehouse.all
    @warehouses = @warehouses.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.js
    end
  end
  
  private

  def warehouse_params
    params.require(:warehouse).permit(:name, :_type)
  end
  
end