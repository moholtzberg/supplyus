class ItemsController < ApplicationController
  layout "admin"
  respond_to :html, :json
  def index
    @items = Item.all
    unless params[:keywords].blank?
      @items = @items.search(params[:keywords]) if params[:keywords].present?
    end
    @items = @items.paginate(:page => params[:page], :per_page => 25)
  end
  
  def new
    @item = Item.new
    # @brands = Brand.active
    # @categories = Category.all
  end
  
  def show
    @item = Item.find_by(:id => params[:id])
  end
  
  def search
    @results = Item.where(nil)
    @results = @results.search(params[:keywords]) if params[:keywords].present?
    respond_to do |format|
      format.json { render json: @results }
    end
  end
  
  def create
    @item = Item.create(registration_params)
    @items = Item.all
    @items = @items.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def edit
    @item = Item.find_by(:id => params[:id])
    # @brands = Brand.active
    # @categories = Category.all
  end
  
  def update
    @item = Item.find_by(:id => params[:id])
    if @item.update_attributes(registration_params)
      flash[:notice] = "\"#{@item.number}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    @items = Item.all
    @items = @items.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.js
      format.json do 
        respond_with_bip(@item)
      end
    end
    
  end
  
  private

  def registration_params
    params.require(:item).permit(:number, :description, :price, :cost_price, :sale_price, :model_id, :is_serialized, :weight, :height, :width, :length, :item_type_id, :category_id, :brand_id, :brand_name, :category_name)
  end
  
end