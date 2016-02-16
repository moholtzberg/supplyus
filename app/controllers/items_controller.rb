class ItemsController < ApplicationController
  layout "admin"
  
  def index
    @items = Item.all
    unless params[:keywords].blank?
      @items = @items.search(params[:keywords]) if params[:keywords].present?
    end
    @items = @items.paginate(:page => params[:page], :per_page => 25)
  end
  
  def new
    @item = Item.new
    @brands = Brand.active
    @categories = Category.all
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
    @item = Item.create(:number => params[:item][:number], :description => params[:item][:description], :price => params[:item][:price], :cost_price => params[:item][:cost_price], :sale_price => params[:item][:sale_price], :weight => params[:item][:weight], :height => params[:item][:height], :width => params[:item][:width], :length => params[:item][:length], :is_serialized => params[:item][:is_serialized], :item_type_id => params[:item][:item_type_id], :category_id => params[:item][:category_id], :brand_id => params[:item][:brand_id])
    @items = Item.all
  end
  
  def edit
    @item = Item.find_by(:id => params[:id])
    @brands = Brand.active
    @categories = Category.all
  end
  
  def update
    @item = Item.find_by(:id => params[:id])
    if @item.update_attributes(:number => params[:item][:number], :description => params[:item][:description], :price => params[:item][:price], :cost_price => params[:item][:cost_price], :sale_price => params[:item][:sale_price], :weight => params[:item][:weight], :height => params[:item][:height], :width => params[:item][:width], :length => params[:item][:length], :is_serialized => params[:item][:is_serialized], :item_type_id => params[:item][:item_type_id], :category_id => params[:item][:category_id], :brand_id => params[:item][:brand_id])
      flash[:notice] = "\"#{@item.number}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    @items = Item.all
  end
  
  private

  def registration_params
    params.require(:item).permit(:number, :description, :price, :cost_price, :sale_price, :model_id, :is_serialized, :weight, :height, :width, :length, :item_type_id, :category_id, :brand_id)
  end
  
end