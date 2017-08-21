class BrandsController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_brand, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  def index
    update_index
    respond_to do |format|
      format.html
      format.js
      format.json {render :json => @brands.map(&:name)}
    end
  end
  
  def new
    @brand = Brand.new
  end
  
  def show
    @items = @brand.items
    unless params[:term].blank?
      @items = @items.lookup(params[:term]) if params[:term].present?
    end
    @items = @items.paginate(:page => params[:page], :per_page => 25)
  end
  
  def create
    @brand = Brand.create(brand_params)
    update_index
  end
  
  def edit
  end
  
  def update
    @brand.update_attributes(brand_params)
    update_index
  end
  
  def destroy
    @brand.destroy
    update_index
  end
  
  private

  def set_brand
    @brand = Brand.find(params[:id])
  end

  def update_index
    @brands = Brand.order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @brands = @brands.lookup(params[:term]) if params[:term].present?
    end
    @brands = @brands.paginate(:page => params[:page], :per_page => 25)
  end

  def brand_params
    params.require(:brand).permit(:name, :active, :preferred, :prefix)
  end
  
  def sort_column
    Brand.column_names.include?(params[:sort]) ? params[:sort] : "brands.name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end